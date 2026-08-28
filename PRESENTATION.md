# Small Business Database Management System

## IT 125 SQL Project - Summer 2026

---

## 📊 Slide 1: Project Overview

### Small Business Database Management System

**Objective:** Centralize business data into a structured relational database

**Problem Solved:**

- ❌ Data scattered across spreadsheets, receipts, and paper records
- ❌ Duplicate entries and inconsistent information
- ❌ Difficulty generating business insights

**Solution:**

- ✅ Single source of truth for all business operations
- ✅ Maintains data integrity through relationships and constraints
- ✅ Enables powerful analytics and reporting
- ✅ Improves decision-making with accurate data

---

## 🗄️ Slide 2: Database Architecture

### 8 Interconnected Tables

The database is built on **relational principles** with strict normalization to eliminate redundancy:

```
CUSTOMERS ─────→ SALES ←───── SALES_LINE_ITEMS ←───── PRODUCTS
   ↑                                                         ↑
   │                                                         │
   └─────────────────────────────────────────────────────────┘

VENDORS ─────→ INVENTORY_ITEMS ←───── PRODUCTS
   ↑
   │
EXPENSES

COMPLIANCE_ITEMS (Independent)
```

**Key Principles:**

- Primary keys ensure unique identification
- Foreign keys maintain referential integrity
- Normalization reduces data duplication

---

## 👥 Slide 3: Customers Table

### Storing Customer Information

| Column                                        | Type      | Purpose                |
| --------------------------------------------- | --------- | ---------------------- |
| `customer_id`                                 | INT (PK)  | Unique identifier      |
| `first_name`, `last_name`                     | VARCHAR   | Customer name          |
| `email`, `phone`                              | VARCHAR   | Contact information    |
| `street_address`, `city`, `state`, `zip_code` | VARCHAR   | Physical address       |
| `customer_since`                              | DATE      | Account creation       |
| `loyalty_points`                              | MEDIUMINT | Rewards tracking       |
| `active`                                      | TINYINT   | Soft-delete flag (1/0) |

**Why This Design?**

- Preserves sales history even after deactivating customers
- Supports loyalty program tracking
- Enables location-based analysis

---

## 🏭 Slide 4: Vendors & Suppliers

### Managing Business Relationships

| Column                        | Type     | Purpose                  |
| ----------------------------- | -------- | ------------------------ |
| `vendor_id`                   | INT (PK) | Unique identifier        |
| `vendor_name`, `contact_name` | VARCHAR  | Company info             |
| `email`, `phone`              | VARCHAR  | Contact details          |
| `city`, `state`               | VARCHAR  | Location                 |
| `payment_terms`               | VARCHAR  | Billing (e.g., "Net 30") |
| `active`                      | TINYINT  | Vendor status            |

**Connected Tables:**

- Inventory Items (supplies from vendors)
- Expenses (payments to vendors)

---

## 📦 Slide 5: Products & Inventory

### Two-Layer Inventory System

#### Products Table (Master Catalog)

- Static list of all items the business sells
- Stores pricing and cost information
- `unit_price` and `unit_cost` (DECIMAL 10,2 for precision)

#### Inventory Items Table (Dynamic Stock)

- Real-time warehouse/store stock levels
- Links products with vendors
- Tracks reorder points to prevent stockouts
- `last_updated` timestamp for audit trail

**Example Workflow:**

1. Product created in catalog
2. Inventory item added for specific vendor location
3. Stock levels updated as sales occur
4. Reorder alerts trigger when below threshold

---

## 🛒 Slide 6: Sales Transactions

### Two-Part Transaction Model

#### Sales Table (Header)

- Overall transaction details
- `sale_id`, `customer_id`, `sale_timestamp`
- `payment_method` (Cash, Credit, Check, Digital)
- `sale_status` (Pending, Completed, Refunded, Cancelled)
- Optional notes

#### Sales_Line_Items Table (Detail Lines)

- Individual products within a transaction
- Stores quantity and price at time of sale
- **Important:** Unit price is frozen to maintain historical accuracy
- If master product price changes, receipts remain unchanged

**Example: Customer buys 2 items**

```
SALES record created
└─ SALES_LINE_ITEMS #1: Widget (qty: 1, price: $9.99)
└─ SALES_LINE_ITEMS #2: Gadget (qty: 1, price: $19.99)
```

---

## 💰 Slide 7: Expenses Management

### Tracking Money Out of Business

| Column             | Type         | Purpose                         |
| ------------------ | ------------ | ------------------------------- |
| `expense_id`       | INT (PK)     | Unique identifier               |
| `vendor_id`        | INT (FK)     | Which supplier                  |
| `expense_name`     | VARCHAR      | Description                     |
| `expense_category` | ENUM         | Type (Utilities, Payroll, etc.) |
| `amount`           | DECIMAL 10,2 | Cost amount                     |
| `expense_date`     | DATE         | When incurred                   |
| `due_date`         | DATE         | Payment deadline                |
| `paid`             | TINYINT      | Payment status                  |
| `frequency`        | ENUM         | Monthly, One-Time, etc.         |

**Business Value:**

- Tracks accounts payable
- Identifies overdue payments
- Supports budget forecasting

---

## ✅ Slide 8: Compliance & Regulations

### Regulatory Requirements Management

| Column                          | Type     | Purpose                           |
| ------------------------------- | -------- | --------------------------------- |
| `compliance_item_id`            | INT (PK) | Unique identifier                 |
| `item_name`                     | VARCHAR  | License/requirement name          |
| `item_type`                     | ENUM     | Type (License, Insurance, Permit) |
| `issuing_authority`             | VARCHAR  | Government agency                 |
| `issue_date`, `expiration_date` | DATE     | Timeline tracking                 |
| `renewal_status`                | ENUM     | Current status                    |
| `renewal_cost`                  | DECIMAL  | Renewal expense                   |

**Standalone Table Design:**

- Not directly linked to other operations
- Allows independent tracking of legal obligations
- Prevents compliance violations and penalties

---

## 📈 Slide 9: Key Database Features

### Design Excellence

✅ **Data Normalization**

- Minimizes redundancy
- Ensures consistency
- Easy to update information

✅ **Referential Integrity**

- Foreign keys prevent orphaned records
- Maintains relationships between tables
- Cascading constraints protect data

✅ **Type Safety**

- ENUM fields restrict invalid entries
- DECIMAL for precise currency calculations
- TIMESTAMP for audit trails

✅ **Scalability**

- Lightweight for startups
- Grows with business needs
- Supports complex queries and reporting

✅ **Business Intelligence**

- Sample data enables testing
- Query-ready for analytics
- Supports KPI dashboards

---

## 🔍 Slide 10: Sample Queries

### Real Business Insights

**Top 10 Customers by Revenue**

```sql
SELECT customer_name, order_count, lifetime_revenue
FROM customers_with_sales
ORDER BY lifetime_revenue DESC LIMIT 10;
```

**Monthly Revenue Trend**

```sql
SELECT DATE_FORMAT(sale_timestamp, '%Y-%m') AS month,
       SUM(quantity * unit_price) AS monthly_revenue
FROM sales JOIN sales_line_items
GROUP BY month ORDER BY month;
```

**Inventory Needing Reorder**

```sql
SELECT product_name, stock_count, reorder_level
FROM inventory_items
WHERE stock_count <= reorder_level;
```

**Repeat Customers**

```sql
SELECT customer_name, COUNT(sale_id) AS purchase_count
FROM customers JOIN sales
GROUP BY customer_id
HAVING COUNT(sale_id) > 1;
```

---

## 🎯 Slide 11: Business Benefits

### Impact on Small Business Operations

| Area                | Benefit                                               |
| ------------------- | ----------------------------------------------------- |
| **Sales**           | Track revenue by customer, product, payment method    |
| **Inventory**       | Know stock levels, prevent stockouts, manage waste    |
| **Customers**       | Build loyalty programs, identify top buyers           |
| **Expenses**        | Control costs, track vendor payments, forecast budget |
| **Compliance**      | Never miss renewal deadlines, track certifications    |
| **Analytics**       | Monthly trends, profit margins, growth metrics        |
| **Decision Making** | Data-driven insights instead of guesswork             |

---

## 📊 Slide 12: Data Types & Storage Optimization

### Precision Where It Matters

| Column Type       | Use Case         | Example                                 |
| ----------------- | ---------------- | --------------------------------------- |
| **INT**           | Entity IDs       | customer_id, product_id                 |
| **VARCHAR(100)**  | Names, addresses | first_name, street_address              |
| **DECIMAL(10,2)** | Money            | unit_price, amount (critical precision) |
| **DATE**          | Calendar dates   | customer_since, expense_date            |
| **TIMESTAMP**     | Exact moments    | sale_timestamp, last_updated            |
| **TINYINT(1)**    | Boolean flags    | active, paid (0 or 1)                   |
| **MEDIUMINT**     | Large quantities | loyalty_points, stock_count             |
| **ENUM**          | Fixed choices    | payment_method, sale_status             |
| **SMALLINT**      | Smaller numbers  | quantity in line items                  |

**Result:** Balanced storage efficiency with accuracy

---

## 🔐 Slide 13: Data Integrity & Constraints

### Protecting Business Data

**Primary Keys (PK)**

- Guarantee uniqueness
- Fast lookups
- One per table

**Foreign Keys (FK)**

- Maintain relationships
- Prevent orphaned records
- Example: Sale cannot exist without Customer

**ENUM Constraints**

- Only valid values accepted
- Prevents typos and inconsistency
- Example: payment_method ∈ {Cash, Credit, Check, Digital}

**Check Constraints**

- Enforce business rules
- Example: unit_price > 0

**Soft Deletes (active flag)**

- Deactivate records without erasing
- Preserve sales history
- Enable historical analysis

---

## 🚀 Slide 14: Implementation & Setup

### From Concept to Production

**Files Included:**

- ✅ `smallbiz.sql` - Complete database schema
- ✅ Sample data - Populated test records
- ✅ `smallbiz_insight_queries.sql` - 20+ ready-to-run queries
- ✅ `Data_Dictionary.md` - Field-by-field documentation
- ✅ `Database_Design_Explanation.md` - Architecture rationale

**Quick Start:**

1. Run `smallbiz.sql` in MySQL
2. Verify tables and relationships
3. Execute sample queries
4. Customize for your business

---

## 📚 Slide 15: Query Categories Available

### Ready-to-Use Business Reports

**Customer Analysis**

- Total customers (active vs. inactive)
- New customer signups per month
- Top customers by revenue
- Repeat vs. one-time buyers

**Sales Insights**

- Daily/monthly revenue trends
- Revenue by payment method
- Average order value
- Sales by status

**Product Performance**

- Best-selling products by quantity & revenue
- Revenue and margin by category
- Product profitability analysis
- Low-performing products

**Inventory Management**

- Items below reorder level
- Total inventory value
- Stock turnover rates

**Financial Reports**

- Biggest expenses
- Expense category breakdown
- Overdue payments
- Revenue vs. expense summary
- Vendor spending analysis

**Compliance Tracking**

- Expiring or expired certifications
- Renewal schedules

---

## 💡 Slide 16: Use Cases

### Real-World Business Scenarios

**Scenario 1: Quarterly Review**

- "Are we growing?" → Monthly revenue trends
- "Who are our best customers?" → Top customers by revenue
- "What products drive profit?" → Revenue and margin analysis

**Scenario 2: Inventory Crisis**

- "What's running low?" → Reorder list
- "What's our stock value?" → Inventory value at cost
- "Which items sell fast?" → Inventory turnover rates

**Scenario 3: Budget Planning**

- "What are our expenses?" → Expense category breakdown
- "Who do we pay most?" → Vendor spending analysis
- "Are bills overdue?" → Unpaid expenses list

**Scenario 4: Customer Retention**

- "Who hasn't bought recently?" → Inactive customer analysis
- "Who keeps coming back?" → Repeat customer metrics
- "How often do people buy?" → Purchase frequency analysis

---

## 🎓 Slide 17: Learning Outcomes

### SQL Skills Demonstrated

✅ **Database Design**

- Normalization (3NF principles)
- Entity relationship modeling
- Primary and foreign key usage

✅ **SQL Fundamentals**

- CREATE TABLE with data types
- Relationships and joins
- Constraints and validations

✅ **Query Writing**

- SELECT with WHERE and GROUP BY
- Aggregate functions (SUM, COUNT, AVG)
- Date formatting and calculations
- Ordering and limiting results

✅ **Advanced Concepts**

- Many-to-many relationships (junction tables)
- Historical data preservation
- Soft delete mechanisms
- Business logic in schema design

✅ **Data Analysis**

- Creating meaningful reports
- Trend analysis
- KPI calculations
- Business intelligence queries

---

## 🏁 Slide 18: Conclusion

### Small Business Database Management System

**Project Delivers:**

- Complete, normalized database schema
- 8 interconnected tables covering all business operations
- Sample data for immediate testing
- 20+ ready-to-run analytics queries
- Comprehensive documentation

**Key Achievements:**

- Centralized data management
- Improved data consistency
- Enables business intelligence
- Scalable for growth
- Foundation for additional features

**Future Enhancements:**

- Web application frontend
- Real-time dashboards
- Mobile app integration
- Predictive analytics
- Multi-location support

**Bottom Line:**
A production-ready database solution that transforms scattered business data into actionable insights.

---

## 📞 Slide 19: Project Resources

### Quick Reference

**Database Files:**

- Schema: `smallbiz.sql`
- Documentation: `README.md`
- Data Dictionary: `Documentation/Data_Dictionary.md`
- Sample Queries: `SQL/smallbiz_insight_queries.sql`

**Entity Relationship Diagram (ERD):**

- Located in: `ERD/` folder
- Visual representation of table relationships

**Sample Data:**

- Located in: `Sample_Data/` folder
- Realistic business records for testing

**Questions to Explore:**

1. How would you add product reviews/ratings?
2. How would you track customer returns?
3. How would you support multiple warehouse locations?
4. How would you implement user permissions?

---

## 🎉 End of Presentation

### Thank You!

**Small Business Database Management System**  
_IT 125 SQL | Summer 2026_

---
