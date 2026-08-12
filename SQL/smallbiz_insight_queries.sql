USE smallbiz;

-- ============================================================
-- Customers
-- ============================================================

-- Total number of customers, and how many are currently active
SELECT
    COUNT(*)                                   AS total_customers,
    SUM(active)                                AS active_customers,
    COUNT(*) - SUM(active)                     AS inactive_customers
FROM customers;

-- New customers signed up per month
SELECT
    DATE_FORMAT(customer_since, '%Y-%m') AS signup_month,
    COUNT(*)                             AS new_customers
FROM customers
GROUP BY signup_month
ORDER BY signup_month;

-- Top customers by lifetime revenue
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT s.sale_id)              AS order_count,
    SUM(sli.quantity * sli.unit_price)     AS lifetime_revenue
FROM customers AS c
JOIN sales AS s
    ON c.customer_id = s.customer_id
JOIN sales_line_items AS sli
    ON s.sale_id = sli.sale_id
WHERE s.sale_status = 'Completed'
GROUP BY c.customer_id, customer_name
ORDER BY lifetime_revenue DESC
LIMIT 10;

-- ============================================================
-- Transactions and revenue
-- ============================================================

-- Number of transactions and revenue per day
SELECT
    DATE(s.sale_timestamp)             AS sale_date,
    COUNT(DISTINCT s.sale_id)          AS transaction_count,
    SUM(sli.quantity * sli.unit_price) AS daily_revenue
FROM sales AS s
JOIN sales_line_items AS sli
    ON s.sale_id = sli.sale_id
WHERE s.sale_status = 'Completed'
GROUP BY sale_date
ORDER BY sale_date;

-- Number of transactions and revenue per month
SELECT
    DATE_FORMAT(s.sale_timestamp, '%Y-%m') AS sale_month,
    COUNT(DISTINCT s.sale_id)              AS transaction_count,
    SUM(sli.quantity * sli.unit_price)     AS monthly_revenue
FROM sales AS s
JOIN sales_line_items AS sli
    ON s.sale_id = sli.sale_id
WHERE s.sale_status = 'Completed'
GROUP BY sale_month
ORDER BY sale_month;

-- Transaction count and revenue by payment method
SELECT
    s.payment_method,
    COUNT(DISTINCT s.sale_id)          AS transaction_count,
    SUM(sli.quantity * sli.unit_price) AS revenue
FROM sales AS s
JOIN sales_line_items AS sli
    ON s.sale_id = sli.sale_id
WHERE s.sale_status = 'Completed'
GROUP BY s.payment_method
ORDER BY revenue DESC;

-- Sales counts by status (completed, pending, refunded, cancelled)
SELECT
    sale_status,
    COUNT(*) AS sale_count
FROM sales
GROUP BY sale_status
ORDER BY sale_count DESC;

-- Average order value (completed sales only)
SELECT
    ROUND(SUM(sli.quantity * sli.unit_price) / COUNT(DISTINCT s.sale_id), 2) AS avg_order_value
FROM sales AS s
JOIN sales_line_items AS sli
    ON s.sale_id = sli.sale_id
WHERE s.sale_status = 'Completed';

-- ============================================================
-- Products
-- ============================================================

-- Best-selling products by quantity and revenue
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(sli.quantity)                  AS units_sold,
    SUM(sli.quantity * sli.unit_price) AS product_revenue
FROM sales_line_items AS sli
JOIN products AS p
    ON sli.product_id = p.product_id
JOIN sales AS s
    ON sli.sale_id = s.sale_id
WHERE s.sale_status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY product_revenue DESC;

-- Revenue and margin by product category
SELECT
    p.category,
    SUM(sli.quantity * sli.unit_price)                    AS category_revenue,
    SUM(sli.quantity * p.unit_cost)                       AS category_cost,
    SUM(sli.quantity * (sli.unit_price - p.unit_cost))    AS category_profit
FROM sales_line_items AS sli
JOIN products AS p
    ON sli.product_id = p.product_id
JOIN sales AS s
    ON sli.sale_id = s.sale_id
WHERE s.sale_status = 'Completed'
GROUP BY p.category
ORDER BY category_profit DESC;

-- ============================================================
-- Inventory
-- ============================================================

-- Inventory items that need to be ordered (at or below reorder level)
SELECT
    p.product_id,
    p.product_name,
    v.vendor_name,
    i.stock_count,
    i.reorder_level,
    (i.reorder_level - i.stock_count) AS units_short
FROM inventory_items AS i
JOIN products AS p
    ON i.product_id = p.product_id
JOIN vendors AS v
    ON i.vendor_id = v.vendor_id
WHERE i.stock_count <= i.reorder_level
ORDER BY units_short DESC;

-- Total inventory value on hand (at cost)
SELECT
    SUM(i.stock_count * p.unit_cost) AS inventory_value_at_cost
FROM inventory_items AS i
JOIN products AS p
    ON i.product_id = p.product_id;

-- ============================================================
-- Expenses
-- ============================================================

-- Biggest expenses (top 10 by amount)
SELECT
    e.expense_id,
    e.expense_name,
    e.expense_category,
    v.vendor_name,
    e.amount,
    e.expense_date,
    e.paid
FROM expenses AS e
LEFT JOIN vendors AS v
    ON e.vendor_id = v.vendor_id
ORDER BY e.amount DESC
LIMIT 10;

-- Total spend by expense category
SELECT
    expense_category,
    COUNT(*)     AS expense_count,
    SUM(amount)  AS total_spent
FROM expenses
GROUP BY expense_category
ORDER BY total_spent DESC;

-- Unpaid expenses, most overdue first
SELECT
    expense_id,
    expense_name,
    expense_category,
    amount,
    due_date,
    DATEDIFF(CURDATE(), due_date) AS days_overdue
FROM expenses
WHERE paid = 0
ORDER BY due_date;

-- Revenue vs. expenses summary (all-time)
SELECT
    (SELECT SUM(sli.quantity * sli.unit_price)
     FROM sales AS s
     JOIN sales_line_items AS sli ON s.sale_id = sli.sale_id
     WHERE s.sale_status = 'Completed')           AS total_revenue,
    (SELECT SUM(amount) FROM expenses)             AS total_expenses,
    (SELECT SUM(sli.quantity * sli.unit_price)
     FROM sales AS s
     JOIN sales_line_items AS sli ON s.sale_id = sli.sale_id
     WHERE s.sale_status = 'Completed')
    - (SELECT SUM(amount) FROM expenses)           AS net_income;
a
-- ============================================================
-- Vendors
-- ============================================================

-- Total amount spent per vendor
SELECT
    v.vendor_id,
    v.vendor_name,
    COUNT(e.expense_id) AS expense_count,
    SUM(e.amount)        AS total_spent
FROM vendors AS v
JOIN expenses AS e
    ON v.vendor_id = e.vendor_id
GROUP BY v.vendor_id, v.vendor_name
ORDER BY total_spent DESC;

-- ============================================================
-- Compliance
-- ============================================================

-- Compliance items expiring soon or already expired
SELECT
    compliance_item_id,
    item_name,
    item_type,
    expiration_date,
    renewal_status,
    renewal_cost,
    DATEDIFF(expiration_date, CURDATE()) AS days_until_expiration
FROM compliance_items
WHERE renewal_status IN ('Due Soon', 'Expired')
ORDER BY expiration_date;
