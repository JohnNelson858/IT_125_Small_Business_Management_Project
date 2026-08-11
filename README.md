# Small Business Database Management System
**Course:** IT 125 SQL (Summer 2026)

## Project Overview
This database was designed to help small businesses organize information that is traditionally scattered across spreadsheets, receipts, calendars, and paper records. By centralizing this data into a structured relational database, the system reduces duplicate entries, improves data consistency.

## Database Architecture
The database schema separates core business entities into distinct, related tables. Primary and foreign keys are strictly utilized to maintain relationships between these tables and preserve overall data integrity.


## Database Schema & Table Descriptions
### Core Tables

## Database Schema & Table Descriptions

To ensure data integrity, maintain normalization, and reduce redundancy, the system is structured into seven primary tables. Each table serves a distinct operational purpose:

### 1. `customers` Table
Stores contact, location, and account details for clients.
* **`customer_id` (INT):** Primary Key.
* **`first_name`, `last_name` (VARCHAR 50):** Client name.
* **`email` (VARCHAR 100), `phone` (VARCHAR 20):** Contact information.
* **`street_address` (VARCHAR 100), `city` (VARCHAR 50), `state` (CHAR 2), `zip_code` (VARCHAR 10):** Physical address. State is strictly limited to 2 characters for standard abbreviations.
* **`customer_since` (DATE):** Account creation date.
* **`loyalty_points` (MEDIUMINT):** Rewards tracking.
* **`active` (TINYINT 1):** Boolean flag (1/0) acting as a soft-delete mechanism to deactivate customers without erasing their sales history.

### 2. `vendors` Table
Manages suppliers providing goods or services to the business.
* **`vendor_id` (INT):** Primary Key.
* **`vendor_name` (VARCHAR 255), `contact_name` (VARCHAR 100):** Company and rep details.
* **`email` (VARCHAR 100), `phone` (VARCHAR 20):** Supplier contact information.
* **`city` (VARCHAR 50), `state` (CHAR 2):** Location.
* **`payment_terms` (VARCHAR 30):** Billing arrangements (e.g., "Net 30").
* **`active` (TINYINT 1):** Boolean flag indicating if the vendor relationship is active.

### 3. `products` Table
Acts as the master static catalog of all items the business sells.
* **`product_id` (INT):** Primary Key.
* **`product_name` (VARCHAR 255), `category` (VARCHAR 50):** Item classification.
* **`unit_price`, `unit_cost` (DECIMAL 10,2):** Financial data types storing numbers up to 10 digits with exactly 2 decimal places for precise currency handling.
* **`active` (TINYINT 1):** Boolean flag to toggle availability in the catalog.

### 4. `inventory_items` Table
Tracks dynamic physical stock levels in the warehouse/store. 
* **`inventory_item_id` (INT):** Primary Key.
* **`product_id` (INT):** Foreign Key linking to the master product catalog.
* **`vendor_id` (INT):** Foreign Key linking to the supplier of the item.
* **`stock_count`, `reorder_level` (MEDIUMINT):** Allows tracking of large stock quantities.
* **`last_updated` (DATETIME):** Timestamp recording the exact moment stock counts were modified.

### 5. `sales` Table
Records the overarching details (the header) of a customer transaction.
* **`sale_id` (INT):** Primary Key.
* **`customer_id` (INT):** Foreign Key linking the sale to a specific customer profile.
* **`sale_timestamp` (TIMESTAMP):** Records the exact date and time the transaction occurred.
* **`payment_method`, `sale_status` (ENUM):** Restricts data entry to predefined lists (e.g., 'Pending', 'Completed', 'Refunded') to ensure strict consistency.
* **`notes` (VARCHAR 255):** Optional field for manual transaction notes.

### 6. `sales_line_items` Table
A junction table resolving the many-to-many relationship between sales and products. It lists the individual items bought within a single transaction.
* **`sale_line_item_id` (INT):** Primary Key.
* **`sale_id` (INT):** Foreign Key linking back to the parent transaction header.
* **`product_id` (INT):** Foreign Key linking to the specific catalog item purchased.
* **`quantity` (SMALLINT):** Uses a smaller integer range to optimize storage.
* **`unit_price` (DECIMAL 10,2):** Copies the product price at the time of sale. This ensures historical receipts remain accurate even if the master product price changes later.

### 7. `expenses` Table
Logs money leaving the business to pay for operations, bills, and supplies.
* **`expense_id` (INT):** Primary Key.
* **`vendor_id` (INT):** Foreign Key linking the expense to a specific supplier.
* **`expense_name` (VARCHAR 100):** Description of the cost.
* **`expense_category`, `frequency` (ENUM):** Enforces strict categorization (e.g., 'Utilities', 'Payroll') and frequencies (e.g., 'Monthly', 'One-Time').
* **`amount` (DECIMAL 10,2):** Precise monetary value.
* **`expense_date`, `due_date` (DATE):** Payment timelines.
* **`paid` (TINYINT 1):** Boolean checkbox (1/0) for tracking paid vs. unpaid accounts payable.
* **`notes` (VARCHAR 255):** Additional details.

### 8. `compliance_items` Table
A standalone operational table tracking regulatory, legal, and safety requirements.
* **`compliance_item_id` (INT):** Primary Key.
* **`item_name` (VARCHAR 120), `item_type` (ENUM):** Name and structured category of the compliance item.
* **`issuing_authority` (VARCHAR 100):** The governing body or agency.
* **`issue_date`, `expiration_date` (DATE):** Crucial timeline tracking for renewals.
* **`renewal_status` (ENUM):** Restricts status to predefined values.
* **`renewal_cost` (DECIMAL 10,2):** Expected cost for renewing the item.
* **`notes` (VARCHAR 255):** Additional tracking information.

## Key Features
* **Data Normalization:** Structured to minimize redundancy and ensure data consistency across the business.
* **Robust Inventory Management:** Tracks real-time stock levels independently from product catalogs.
* **Scalability:** Designed to remain lightweight for a startup while easily supporting future expansion and more complex queries.
* **Simulation-Ready:** Populated with sample data to demonstrate typical business operations and support query testing.
