-- Quarterly Database Project Part 2: Design
-- Merged Small Business Startup Management Database
-- Combines the startup_management and smallbiz designs
-- MySQL 8.0 compatible
-- Eight related tables with approximately 40 sample rows per table

DROP SCHEMA IF EXISTS smallbiz;
CREATE SCHEMA smallbiz;
USE smallbiz;

DROP TABLE IF EXISTS customers;
CREATE TABLE customers
(
    customer_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name        VARCHAR(50) NOT NULL,
    last_name         VARCHAR(50) NOT NULL,
    email             VARCHAR(100) NOT NULL,
    phone             VARCHAR(20),
    street_address    VARCHAR(100),
    city              VARCHAR(50),
    state             CHAR(2),
    zip_code          VARCHAR(10),
    customer_since    DATE NOT NULL,
    loyalty_points    MEDIUMINT UNSIGNED NOT NULL DEFAULT 0,
    active            BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uq_customers_email UNIQUE (email)
) ENGINE = InnoDB;
ALTER TABLE customers AUTO_INCREMENT = 1001;

CREATE TABLE vendors
(
    vendor_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    vendor_name       VARCHAR(255) NOT NULL,
    contact_name      VARCHAR(100),
    email             VARCHAR(100),
    phone             VARCHAR(20),
    city              VARCHAR(50),
    state             CHAR(2),
    payment_terms     VARCHAR(30),
    active            BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_vendors PRIMARY KEY (vendor_id)
) ENGINE = InnoDB;
ALTER TABLE vendors AUTO_INCREMENT = 2001;

CREATE TABLE products
(
    product_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    product_name      VARCHAR(255) NOT NULL,
    category          VARCHAR(50) NOT NULL,
    unit_price        DECIMAL(10,2) NOT NULL,
    unit_cost         DECIMAL(10,2) NOT NULL,
    active            BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_products PRIMARY KEY (product_id),
    CONSTRAINT chk_products_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_products_unit_cost CHECK (unit_cost >= 0)
) ENGINE = InnoDB;
ALTER TABLE products AUTO_INCREMENT = 3001;

CREATE TABLE sales
(
    sale_id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id       INT UNSIGNED,
    sale_timestamp    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method    ENUM('Cash','Credit Card','Debit Card','Online') NOT NULL,
    sale_status       ENUM('Completed','Pending','Refunded','Cancelled')
                      NOT NULL DEFAULT 'Completed',
    notes             VARCHAR(255),
    CONSTRAINT pk_sales PRIMARY KEY (sale_id)
) ENGINE = InnoDB;
ALTER TABLE sales AUTO_INCREMENT = 4001;

CREATE TABLE sales_line_items
(
    sale_line_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    sale_id           INT UNSIGNED NOT NULL,
    product_id        INT UNSIGNED NOT NULL,
    quantity          SMALLINT UNSIGNED NOT NULL,
    unit_price        DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_sales_line_items PRIMARY KEY (sale_line_item_id),
    CONSTRAINT uq_sales_line_items_sale_product UNIQUE (sale_id, product_id),
    CONSTRAINT chk_sales_line_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_sales_line_items_unit_price CHECK (unit_price >= 0)
) ENGINE = InnoDB;
ALTER TABLE sales_line_items AUTO_INCREMENT = 4501;

CREATE TABLE inventory_items
(
    inventory_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    product_id        INT UNSIGNED NOT NULL,
    vendor_id         INT UNSIGNED NOT NULL,
    stock_count       MEDIUMINT UNSIGNED NOT NULL DEFAULT 0,
    reorder_level     MEDIUMINT UNSIGNED NOT NULL DEFAULT 0,
    last_updated      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                      ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_inventory_items PRIMARY KEY (inventory_item_id),
    CONSTRAINT uq_inventory_items_product_vendor UNIQUE (product_id, vendor_id),
    CONSTRAINT chk_inventory_items_reorder CHECK (reorder_level >= 0)
) ENGINE = InnoDB;
ALTER TABLE inventory_items AUTO_INCREMENT = 5001;

CREATE TABLE expenses
(
    expense_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
    vendor_id         INT UNSIGNED,
    expense_name      VARCHAR(100) NOT NULL,
    expense_category  ENUM('Rent','Utilities','Insurance','Supplies','Marketing',
                           'Payroll','Software','Maintenance',
                           'Professional Services','Other') NOT NULL,
    amount            DECIMAL(10,2) NOT NULL,
    expense_date      DATE NOT NULL,
    due_date          DATE,
    frequency         ENUM('One-Time','Weekly','Monthly','Quarterly','Annual')
                      NOT NULL,
    paid              BOOLEAN NOT NULL DEFAULT FALSE,
    notes             VARCHAR(255),
    CONSTRAINT pk_expenses PRIMARY KEY (expense_id),
    CONSTRAINT chk_expenses_amount CHECK (amount >= 0)
) ENGINE = InnoDB;
ALTER TABLE expenses AUTO_INCREMENT = 6001;

CREATE TABLE compliance_items
(
    compliance_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    item_name          VARCHAR(120) NOT NULL,
    item_type          ENUM('License','Permit','Insurance','Certification')
                       NOT NULL,
    issuing_authority  VARCHAR(100) NOT NULL,
    issue_date         DATE,
    expiration_date    DATE NOT NULL,
    renewal_status     ENUM('Current','Due Soon','Submitted','Renewed','Expired')
                       NOT NULL,
    renewal_cost       DECIMAL(10,2) NOT NULL DEFAULT 0,
    notes              VARCHAR(255),
    CONSTRAINT pk_compliance_items PRIMARY KEY (compliance_item_id),
    CONSTRAINT chk_compliance_items_cost CHECK (renewal_cost >= 0)
) ENGINE = InnoDB;
ALTER TABLE compliance_items AUTO_INCREMENT = 7001;

-- Foreign-key relationships
ALTER TABLE sales
ADD CONSTRAINT fk_sales_customers
FOREIGN KEY (customer_id)
REFERENCES customers (customer_id)
ON UPDATE NO ACTION
ON DELETE SET NULL;

ALTER TABLE sales_line_items
ADD CONSTRAINT fk_sales_line_items_sales
FOREIGN KEY (sale_id)
REFERENCES sales (sale_id)
ON UPDATE NO ACTION
ON DELETE CASCADE;

ALTER TABLE sales_line_items
ADD CONSTRAINT fk_sales_line_items_products
FOREIGN KEY (product_id)
REFERENCES products (product_id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE inventory_items
ADD CONSTRAINT fk_inventory_items_products
FOREIGN KEY (product_id)
REFERENCES products (product_id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE inventory_items
ADD CONSTRAINT fk_inventory_items_vendors
FOREIGN KEY (vendor_id)
REFERENCES vendors (vendor_id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE expenses
ADD CONSTRAINT fk_expenses_vendors
FOREIGN KEY (vendor_id)
REFERENCES vendors (vendor_id)
ON UPDATE NO ACTION
ON DELETE SET NULL;

-- Create indexes
CREATE INDEX idx_products_category
ON products (category);

CREATE INDEX idx_sales_timestamp
ON sales (sale_timestamp);

-- 40 customers
INSERT INTO customers
(first_name, last_name, email, phone, street_address, city, state, zip_code,
 customer_since, loyalty_points, active)
VALUES
('Ava','Turner','ava.turner@example.com','206-555-1000','100 Main Street','Seattle','WA','98101','2024-01-05',0,1),
('Liam','Brooks','liam.brooks@example.com','206-555-1001','101 Main Street','Tacoma','WA','98402','2024-01-22',75,1),
('Mia','Nguyen','mia.nguyen@example.com','206-555-1002','102 Main Street','Bellevue','WA','98004','2024-02-08',150,1),
('Noah','Patel','noah.patel@example.com','206-555-1003','103 Main Street','Everett','WA','98201','2024-02-25',225,1),
('Emma','Carter','emma.carter@example.com','206-555-1004','104 Main Street','Renton','WA','98057','2024-03-13',300,1),
('Ethan','Reed','ethan.reed@example.com','206-555-1005','105 Main Street','Kent','WA','98030','2024-03-30',375,1),
('Olivia','Garcia','olivia.garcia@example.com','206-555-1006','106 Main Street','Spokane','WA','99201','2024-04-16',450,1),
('Lucas','Kim','lucas.kim@example.com','206-555-1007','107 Main Street','Olympia','WA','98501','2024-05-03',525,1),
('Sophia','Wilson','sophia.wilson@example.com','206-555-1008','108 Main Street','Seattle','WA','98101','2024-05-20',600,1),
('Mason','Anderson','mason.anderson@example.com','206-555-1009','109 Main Street','Tacoma','WA','98402','2024-06-06',675,1),
('Isabella','Thomas','isabella.thomas@example.com','206-555-1010','110 Main Street','Bellevue','WA','98004','2024-06-23',750,1),
('Logan','Moore','logan.moore@example.com','206-555-1011','111 Main Street','Everett','WA','98201','2024-07-10',825,0),
('Amelia','Jackson','amelia.jackson@example.com','206-555-1012','112 Main Street','Renton','WA','98057','2024-07-27',900,1),
('James','Martin','james.martin@example.com','206-555-1013','113 Main Street','Kent','WA','98030','2024-08-13',975,1),
('Harper','Lee','harper.lee@example.com','206-555-1014','114 Main Street','Spokane','WA','99201','2024-08-30',1050,1),
('Benjamin','Perez','benjamin.perez@example.com','206-555-1015','115 Main Street','Olympia','WA','98501','2024-09-16',1125,1),
('Evelyn','Thompson','evelyn.thompson@example.com','206-555-1016','116 Main Street','Seattle','WA','98101','2024-10-03',1200,1),
('Elijah','White','elijah.white@example.com','206-555-1017','117 Main Street','Tacoma','WA','98402','2024-10-20',1275,1),
('Abigail','Harris','abigail.harris@example.com','206-555-1018','118 Main Street','Bellevue','WA','98004','2024-11-06',1350,1),
('Henry','Sanchez','henry.sanchez@example.com','206-555-1019','119 Main Street','Everett','WA','98201','2024-11-23',1425,1),
('Ella','Clark','ella.clark@example.com','206-555-1020','120 Main Street','Renton','WA','98057','2024-12-10',1500,1),
('Alexander','Ramirez','alexander.ramirez@example.com','206-555-1021','121 Main Street','Kent','WA','98030','2024-12-27',1575,1),
('Scarlett','Lewis','scarlett.lewis@example.com','206-555-1022','122 Main Street','Spokane','WA','99201','2025-01-13',1650,1),
('Daniel','Robinson','daniel.robinson@example.com','206-555-1023','123 Main Street','Olympia','WA','98501','2025-01-30',1725,1),
('Grace','Walker','grace.walker@example.com','206-555-1024','124 Main Street','Seattle','WA','98101','2025-02-16',1800,1),
('Matthew','Young','matthew.young@example.com','206-555-1025','125 Main Street','Tacoma','WA','98402','2025-03-05',1875,1),
('Chloe','Allen','chloe.allen@example.com','206-555-1026','126 Main Street','Bellevue','WA','98004','2025-03-22',1950,1),
('Jackson','King','jackson.king@example.com','206-555-1027','127 Main Street','Everett','WA','98201','2025-04-08',2025,0),
('Victoria','Wright','victoria.wright@example.com','206-555-1028','128 Main Street','Renton','WA','98057','2025-04-25',2100,1),
('Sebastian','Scott','sebastian.scott@example.com','206-555-1029','129 Main Street','Kent','WA','98030','2025-05-12',2175,1),
('Riley','Green','riley.green@example.com','206-555-1030','130 Main Street','Spokane','WA','99201','2025-05-29',2250,1),
('David','Baker','david.baker@example.com','206-555-1031','131 Main Street','Olympia','WA','98501','2025-06-15',2325,1),
('Aria','Adams','aria.adams@example.com','206-555-1032','132 Main Street','Seattle','WA','98101','2025-07-02',2400,1),
('Joseph','Nelson','joseph.nelson@example.com','206-555-1033','133 Main Street','Tacoma','WA','98402','2025-07-19',2475,1),
('Lily','Hill','lily.hill@example.com','206-555-1034','134 Main Street','Bellevue','WA','98004','2025-08-05',49,1),
('Samuel','Campbell','samuel.campbell@example.com','206-555-1035','135 Main Street','Everett','WA','98201','2025-08-22',124,0),
('Nora','Mitchell','nora.mitchell@example.com','206-555-1036','136 Main Street','Renton','WA','98057','2025-09-08',199,1),
('Owen','Roberts','owen.roberts@example.com','206-555-1037','137 Main Street','Kent','WA','98030','2025-09-25',274,1),
('Zoey','Phillips','zoey.phillips@example.com','206-555-1038','138 Main Street','Spokane','WA','99201','2025-10-12',349,1),
('Gabriel','Evans','gabriel.evans@example.com','206-555-1039','139 Main Street','Olympia','WA','98501','2025-10-29',424,1);

-- 40 vendors
INSERT INTO vendors
(vendor_name, contact_name, email, phone, city, state, payment_terms, active)
VALUES
('Northwest Office Supply','Ava Kim','contact1@vendor.example','425-555-2000','Seattle','WA','Net 15',1),
('Cascade Packaging','Liam Wilson','contact2@vendor.example','425-555-2001','Tacoma','WA','Net 30',1),
('Evergreen Wholesale','Mia Anderson','contact3@vendor.example','425-555-2002','Bellevue','WA','Due on Receipt',1),
('Sound Tech Solutions','Noah Thomas','contact4@vendor.example','425-555-2003','Everett','WA','Net 45',1),
('Rainier Cleaning Supply','Emma Moore','contact5@vendor.example','425-555-2004','Renton','WA','Net 15',1),
('Puget Print Works','Ethan Jackson','contact6@vendor.example','425-555-2005','Kent','WA','Net 30',1),
('Harbor Business Services','Olivia Martin','contact7@vendor.example','425-555-2006','Spokane','WA','Due on Receipt',1),
('Olympic Safety Products','Lucas Lee','contact8@vendor.example','425-555-2007','Olympia','WA','Net 45',1),
('Emerald City Foods','Sophia Perez','contact9@vendor.example','425-555-2008','Seattle','WA','Net 15',1),
('Summit Equipment','Mason Thompson','contact10@vendor.example','425-555-2009','Tacoma','WA','Net 30',1),
('Blue Sky Marketing','Isabella White','contact11@vendor.example','425-555-2010','Bellevue','WA','Due on Receipt',1),
('Pacific Coast Insurance','Logan Harris','contact12@vendor.example','425-555-2011','Everett','WA','Net 45',1),
('Metro Internet Services','Amelia Sanchez','contact13@vendor.example','425-555-2012','Renton','WA','Net 15',1),
('Columbia Maintenance','James Clark','contact14@vendor.example','425-555-2013','Kent','WA','Net 30',1),
('Pioneer Accounting','Harper Ramirez','contact15@vendor.example','425-555-2014','Spokane','WA','Due on Receipt',0),
('North Star Software','Benjamin Lewis','contact16@vendor.example','425-555-2015','Olympia','WA','Net 45',1),
('Greenline Logistics','Evelyn Robinson','contact17@vendor.example','425-555-2016','Seattle','WA','Net 15',1),
('Redwood Fixtures','Elijah Walker','contact18@vendor.example','425-555-2017','Tacoma','WA','Net 30',1),
('Seaside Uniforms','Abigail Young','contact19@vendor.example','425-555-2018','Bellevue','WA','Due on Receipt',1),
('Atlas Security','Henry Allen','contact20@vendor.example','425-555-2019','Everett','WA','Net 45',1),
('BrightPath Consulting','Ella King','contact21@vendor.example','425-555-2020','Renton','WA','Net 15',1),
('Lakeview Utilities','Alexander Wright','contact22@vendor.example','425-555-2021','Kent','WA','Net 30',1),
('Urban Sign Company','Scarlett Scott','contact23@vendor.example','425-555-2022','Spokane','WA','Due on Receipt',1),
('Prime Merchant Services','Daniel Green','contact24@vendor.example','425-555-2023','Olympia','WA','Net 45',1),
('Mountain Coffee Roasters','Grace Baker','contact25@vendor.example','425-555-2024','Seattle','WA','Net 15',1),
('Coastal Paper Company','Matthew Adams','contact26@vendor.example','425-555-2025','Tacoma','WA','Net 30',1),
('Vertex Web Services','Chloe Nelson','contact27@vendor.example','425-555-2026','Bellevue','WA','Due on Receipt',1),
('Reliable Repairs','Jackson Hill','contact28@vendor.example','425-555-2027','Everett','WA','Net 45',1),
('Civic Permit Services','Victoria Campbell','contact29@vendor.example','425-555-2028','Renton','WA','Net 15',1),
('Northwest Legal Group','Sebastian Mitchell','contact30@vendor.example','425-555-2029','Kent','WA','Net 30',1),
('Beacon Telecom','Riley Roberts','contact31@vendor.example','425-555-2030','Spokane','WA','Due on Receipt',1),
('Cedar Office Furniture','David Phillips','contact32@vendor.example','425-555-2031','Olympia','WA','Net 45',0),
('Westside Refrigeration','Aria Evans','contact33@vendor.example','425-555-2032','Seattle','WA','Net 15',1),
('Golden State Imports','Joseph Turner','contact34@vendor.example','425-555-2033','Tacoma','WA','Net 30',1),
('Frontier Shipping','Lily Brooks','contact35@vendor.example','425-555-2034','Bellevue','WA','Due on Receipt',1),
('Sunrise Janitorial','Samuel Nguyen','contact36@vendor.example','425-555-2035','Everett','WA','Net 45',1),
('Capital Business Forms','Nora Patel','contact37@vendor.example','425-555-2036','Renton','WA','Net 15',1),
('Peak Energy Services','Owen Carter','contact38@vendor.example','425-555-2037','Kent','WA','Net 30',1),
('Riverbend Supplies','Zoey Reed','contact39@vendor.example','425-555-2038','Spokane','WA','Due on Receipt',1),
('Evergreen Pest Control','Gabriel Garcia','contact40@vendor.example','425-555-2039','Olympia','WA','Net 45',1);

-- 40 products
INSERT INTO products
(product_name, category, unit_price, unit_cost, active)
VALUES
('Starter Notebook','Office Supplies',4.12,2.50,1),
('Premium Notebook','Office Supplies',9.49,5.75,1),
('Ballpoint Pen Set','Office Supplies',14.85,9.00,1),
('Gel Pen Set','Office Supplies',20.21,12.25,1),
('Desk Organizer','Office Supplies',25.57,15.50,1),
('Wireless Mouse','Electronics',30.94,18.75,1),
('USB Keyboard','Electronics',36.30,22.00,1),
('Webcam','Electronics',41.66,25.25,1),
('Headset','Electronics',47.02,28.50,1),
('Laptop Stand','Electronics',52.39,31.75,1),
('Shipping Box Small','Packaging',12.38,7.50,1),
('Shipping Box Medium','Packaging',17.74,10.75,1),
('Shipping Box Large','Packaging',23.10,14.00,1),
('Packing Tape','Packaging',28.46,17.25,1),
('Bubble Wrap','Packaging',33.82,20.50,1),
('All-Purpose Cleaner','Cleaning',39.19,23.75,1),
('Glass Cleaner','Cleaning',44.55,27.00,1),
('Paper Towels','Cleaning',49.91,30.25,1),
('Trash Liners','Cleaning',55.27,33.50,1),
('Hand Soap','Cleaning',60.64,36.75,1),
('Business Card Pack','Printing',20.62,12.50,1),
('Flyer Printing','Printing',25.99,15.75,1),
('Banner Printing','Printing',31.35,19.00,1),
('Coffee Beans','Beverages',36.71,22.25,1),
('Tea Assortment','Beverages',42.07,25.50,1),
('Bottled Water Case','Beverages',47.44,28.75,1),
('Snack Variety Pack','Food',52.80,32.00,1),
('First Aid Kit','Safety',58.16,35.25,1),
('Safety Vest','Safety',63.52,38.50,1),
('Fire Extinguisher','Safety',68.89,41.75,1),
('Printer Paper','Office Supplies',28.88,17.50,1),
('Thermal Receipt Paper','Office Supplies',34.24,20.75,1),
('Label Roll','Office Supplies',39.60,24.00,1),
('Desk Chair','Furniture',44.96,27.25,1),
('Folding Table','Furniture',50.32,30.50,1),
('Storage Shelf','Furniture',55.69,33.75,1),
('LED Desk Lamp','Electronics',61.05,37.00,1),
('Surge Protector','Electronics',66.41,40.25,1),
('Extension Cord','Electronics',71.77,43.50,0),
('Portable Fan','Equipment',77.14,46.75,1);

-- 40 inventory items
INSERT INTO inventory_items
(product_id, vendor_id, stock_count, reorder_level, last_updated)
VALUES
(3001,2001,4,10,'2026-01-02 08:00:00'),
(3002,2002,11,15,'2026-01-05 08:00:00'),
(3003,2003,18,20,'2026-01-08 08:00:00'),
(3004,2004,25,25,'2026-01-11 08:00:00'),
(3005,2005,32,30,'2026-01-14 08:00:00'),
(3006,2006,39,10,'2026-01-17 08:00:00'),
(3007,2007,46,15,'2026-01-20 08:00:00'),
(3008,2008,53,20,'2026-01-23 08:00:00'),
(3009,2009,60,25,'2026-01-26 08:00:00'),
(3010,2010,6,30,'2026-01-29 08:00:00'),
(3011,2011,13,10,'2026-02-01 08:00:00'),
(3012,2012,20,15,'2026-02-04 08:00:00'),
(3013,2013,27,20,'2026-02-07 08:00:00'),
(3014,2014,34,25,'2026-02-10 08:00:00'),
(3015,2015,41,30,'2026-02-13 08:00:00'),
(3016,2016,48,10,'2026-02-16 08:00:00'),
(3017,2017,55,15,'2026-02-19 08:00:00'),
(3018,2018,62,20,'2026-02-22 08:00:00'),
(3019,2019,8,25,'2026-02-25 08:00:00'),
(3020,2020,15,30,'2026-02-28 08:00:00'),
(3021,2021,22,10,'2026-03-03 08:00:00'),
(3022,2022,29,15,'2026-03-06 08:00:00'),
(3023,2023,36,20,'2026-03-09 08:00:00'),
(3024,2024,43,25,'2026-03-12 08:00:00'),
(3025,2025,50,30,'2026-03-15 08:00:00'),
(3026,2026,57,10,'2026-03-18 08:00:00'),
(3027,2027,64,15,'2026-03-21 08:00:00'),
(3028,2028,10,20,'2026-03-24 08:00:00'),
(3029,2029,17,25,'2026-03-27 08:00:00'),
(3030,2030,24,30,'2026-03-30 08:00:00'),
(3031,2031,31,10,'2026-04-02 08:00:00'),
(3032,2032,38,15,'2026-04-05 08:00:00'),
(3033,2033,45,20,'2026-04-08 08:00:00'),
(3034,2034,52,25,'2026-04-11 08:00:00'),
(3035,2035,59,30,'2026-04-14 08:00:00'),
(3036,2036,5,10,'2026-04-17 08:00:00'),
(3037,2037,12,15,'2026-04-20 08:00:00'),
(3038,2038,19,20,'2026-04-23 08:00:00'),
(3039,2039,26,25,'2026-04-26 08:00:00'),
(3040,2040,33,30,'2026-04-29 08:00:00');

-- 40 sales
INSERT INTO sales
(customer_id, sale_timestamp, payment_method, sale_status, notes)
VALUES
(1001,'2026-01-03 09:00:00','Cash','Completed','Repeat customer order'),
(1002,'2026-01-08 10:07:00','Credit Card','Completed',NULL),
(1003,'2026-01-13 11:14:00','Debit Card','Completed',NULL),
(1004,'2026-01-18 12:21:00','Online','Completed',NULL),
(1005,'2026-01-23 13:28:00','Cash','Completed','Repeat customer order'),
(1006,'2026-01-28 14:35:00','Credit Card','Completed',NULL),
(1007,'2026-02-02 15:42:00','Debit Card','Completed',NULL),
(1008,'2026-02-07 16:49:00','Online','Completed',NULL),
(1009,'2026-02-12 09:56:00','Cash','Completed','Repeat customer order'),
(1010,'2026-02-17 10:03:00','Credit Card','Completed',NULL),
(1011,'2026-02-22 11:10:00','Debit Card','Completed',NULL),
(1012,'2026-02-27 12:17:00','Online','Completed',NULL),
(1013,'2026-03-04 13:24:00','Cash','Completed','Repeat customer order'),
(1014,'2026-03-09 14:31:00','Credit Card','Completed',NULL),
(1015,'2026-03-14 15:38:00','Debit Card','Completed',NULL),
(1016,'2026-03-19 16:45:00','Online','Completed',NULL),
(1017,'2026-03-24 09:52:00','Cash','Completed','Repeat customer order'),
(1018,'2026-03-29 10:59:00','Credit Card','Completed',NULL),
(1019,'2026-04-03 11:06:00','Debit Card','Completed',NULL),
(1020,'2026-04-08 12:13:00','Online','Completed',NULL),
(1021,'2026-04-13 13:20:00','Cash','Completed','Repeat customer order'),
(1022,'2026-04-18 14:27:00','Credit Card','Completed',NULL),
(1023,'2026-04-23 15:34:00','Debit Card','Completed',NULL),
(1024,'2026-04-28 16:41:00','Online','Completed',NULL),
(1025,'2026-05-03 09:48:00','Cash','Completed','Repeat customer order'),
(1026,'2026-05-08 10:55:00','Credit Card','Completed',NULL),
(1027,'2026-05-13 11:02:00','Debit Card','Completed',NULL),
(1028,'2026-05-18 12:09:00','Online','Completed',NULL),
(1029,'2026-05-23 13:16:00','Cash','Completed','Repeat customer order'),
(1030,'2026-05-28 14:23:00','Credit Card','Completed',NULL),
(1031,'2026-06-02 15:30:00','Debit Card','Completed',NULL),
(1032,'2026-06-07 16:37:00','Online','Completed',NULL),
(1033,'2026-06-12 09:44:00','Cash','Completed','Repeat customer order'),
(1034,'2026-06-17 10:51:00','Credit Card','Completed',NULL),
(1035,'2026-06-22 11:58:00','Debit Card','Pending',NULL),
(1036,'2026-06-27 12:05:00','Online','Refunded',NULL),
(1037,'2026-07-02 13:12:00','Cash','Cancelled','Repeat customer order'),
(1038,'2026-07-07 14:19:00','Credit Card','Completed',NULL),
(1039,'2026-07-12 15:26:00','Debit Card','Completed',NULL),
(1040,'2026-07-17 16:33:00','Online','Completed',NULL);

-- 40 sales line items
INSERT INTO sales_line_items
(sale_id, product_id, quantity, unit_price)
VALUES
(4001,3001,1,4.12),
(4001,3002,1,9.49),
(4001,3005,1,25.57),
(4002,3002,2,9.49),
(4002,3001,2,4.12),
(4002,3006,1,30.94),
(4003,3003,3,14.85),
(4003,3004,1,20.21),
(4003,3007,2,36.30),
(4004,3004,4,20.21),
(4004,3001,1,4.12),
(4004,3008,1,41.66),
(4005,3005,1,25.57),
(4005,3003,2,14.85),
(4005,3009,1,47.02),
(4006,3006,2,30.94),
(4007,3007,3,36.30),
(4008,3008,4,41.66),
(4009,3009,1,47.02),
(4010,3010,2,52.39),
(4011,3011,3,12.38),
(4012,3012,4,17.74),
(4013,3013,1,23.10),
(4014,3014,2,28.46),
(4015,3015,3,33.82),
(4016,3016,4,39.19),
(4017,3017,1,44.55),
(4018,3018,2,49.91),
(4019,3019,3,55.27),
(4020,3020,4,60.64),
(4021,3021,1,20.62),
(4022,3022,2,25.99),
(4023,3023,3,31.35),
(4024,3024,4,36.71),
(4025,3025,1,42.07),
(4026,3026,2,47.44),
(4027,3027,3,52.80),
(4028,3028,4,58.16),
(4029,3029,1,63.52),
(4030,3030,2,68.89),
(4031,3031,3,28.88),
(4032,3032,4,34.24),
(4033,3033,1,39.60),
(4034,3034,2,44.96),
(4035,3035,3,50.32),
(4036,3036,4,55.69),
(4037,3037,1,61.05),
(4038,3038,2,66.41),
(4039,3039,3,71.77),
(4040,3040,4,77.14);

-- 40 expenses
INSERT INTO expenses
(vendor_id, expense_name, expense_category, amount, expense_date, due_date,
 frequency, paid, notes)
VALUES
(2001,'January Office Rent','Rent',45.00,'2026-01-01','2026-01-15','Monthly',1,NULL),
(2002,'February Office Rent','Rent',132.50,'2026-01-07','2026-01-21','Monthly',1,NULL),
(2003,'March Office Rent','Rent',220.00,'2026-01-13','2026-01-27','Monthly',1,NULL),
(2004,'April Office Rent','Rent',307.50,'2026-01-19','2026-02-02','Monthly',1,NULL),
(2005,'Electric Service','Utilities',395.00,'2026-01-25','2026-02-08','Monthly',1,NULL),
(2006,'Water and Sewer','Utilities',482.50,'2026-01-31','2026-02-14','Monthly',1,NULL),
(2007,'Business Internet','Utilities',570.00,'2026-02-06','2026-02-20','Monthly',1,NULL),
(2008,'Phone Service','Utilities',657.50,'2026-02-12','2026-02-26','Monthly',1,NULL),
(2009,'General Liability Insurance','Insurance',170.00,'2026-02-18','2026-03-04','Annual',1,NULL),
(2010,'Property Insurance','Insurance',257.50,'2026-02-24','2026-03-10','Annual',1,NULL),
(2011,'Workers Compensation Insurance','Insurance',345.00,'2026-03-02','2026-03-16','Annual',1,NULL),
(2012,'Bookkeeping Service','Professional Services',432.50,'2026-03-08','2026-03-22','Monthly',1,NULL),
(2013,'Payroll Processing','Professional Services',520.00,'2026-03-14','2026-03-28','Monthly',1,NULL),
(2014,'Cloud Software Subscription','Software',607.50,'2026-03-20','2026-04-03','Monthly',1,NULL),
(2015,'Website Hosting','Software',695.00,'2026-03-26','2026-04-09','Annual',1,NULL),
(2016,'Email Service','Software',782.50,'2026-04-01','2026-04-15','Monthly',1,NULL),
(2017,'Cleaning Supplies','Supplies',295.00,'2026-04-07','2026-04-21','Monthly',1,NULL),
(2018,'Office Supplies','Supplies',382.50,'2026-04-13','2026-04-27','Monthly',1,NULL),
(2019,'Packaging Materials','Supplies',470.00,'2026-04-19','2026-05-03','Monthly',1,NULL),
(2020,'Equipment Maintenance','Maintenance',557.50,'2026-04-25','2026-05-09','Quarterly',1,NULL),
(2021,'Printer Repair','Maintenance',645.00,'2026-05-01','2026-05-15','One-Time',1,NULL),
(2022,'Advertising Campaign','Marketing',732.50,'2026-05-07','2026-05-21','One-Time',1,NULL),
(2023,'Social Media Ads','Marketing',820.00,'2026-05-13','2026-05-27','Monthly',1,NULL),
(2024,'Local Sponsorship','Marketing',907.50,'2026-05-19','2026-06-02','One-Time',1,NULL),
(2025,'Legal Consultation','Professional Services',420.00,'2026-05-25','2026-06-08','One-Time',0,NULL),
(2026,'Tax Preparation','Professional Services',507.50,'2026-05-31','2026-06-14','Annual',0,NULL),
(2027,'Merchant Processing Fees','Other',595.00,'2026-06-06','2026-06-20','Monthly',0,NULL),
(2028,'Bank Service Fees','Other',682.50,'2026-06-12','2026-06-26','Monthly',0,NULL),
(2029,'Delivery Service','Other',770.00,'2026-06-18','2026-07-02','Weekly',0,NULL),
(2030,'Fuel Reimbursement','Other',857.50,'2026-06-24','2026-07-08','Monthly',0,NULL),
(2031,'Pest Control','Maintenance',945.00,'2026-06-30','2026-07-14','Quarterly',0,NULL),
(2032,'Security Monitoring','Other',1032.50,'2026-07-06','2026-07-20','Monthly',0,NULL),
(2033,'Coffee and Breakroom','Supplies',545.00,'2026-07-12','2026-07-26','Monthly',0,NULL),
(2034,'Uniform Purchase','Supplies',632.50,'2026-07-18','2026-08-01','One-Time',0,NULL),
(2035,'Safety Equipment','Supplies',720.00,'2026-07-24','2026-08-07','One-Time',0,NULL),
(2036,'Annual Software Renewal','Software',807.50,'2026-07-30','2026-08-13','Annual',0,NULL),
(2037,'Permit Application Fee','Other',895.00,'2026-08-05','2026-08-19','One-Time',0,NULL),
(2038,'License Renewal Fee','Other',982.50,'2026-08-11','2026-08-25','Annual',0,NULL),
(2039,'Furniture Purchase','Other',1070.00,'2026-08-17','2026-08-31','One-Time',0,NULL),
(2040,'Emergency Repair','Maintenance',1157.50,'2026-08-23','2026-09-06','One-Time',0,NULL);

-- 40 compliance items
INSERT INTO compliance_items
(item_name, item_type, issuing_authority, issue_date, expiration_date,
 renewal_status, renewal_cost, notes)
VALUES
('License Record 01','License','City of Seattle','2025-01-15','2026-01-15','Current',50.00,'Review renewal requirements before expiration'),
('Permit Record 02','Permit','Washington State','2025-01-23','2026-02-22','Due Soon',125.00,'Review renewal requirements before expiration'),
('Insurance Record 03','Insurance','King County','2025-01-31','2026-04-01','Submitted',200.00,'Review renewal requirements before expiration'),
('Certification Record 04','Certification','Department of Revenue','2025-02-08','2026-02-08','Renewed',275.00,'Review renewal requirements before expiration'),
('License Record 05','License','Labor and Industries','2025-02-16','2026-03-18','Expired',350.00,'Review renewal requirements before expiration'),
('Permit Record 06','Permit','Fire Department','2025-02-24','2026-04-25','Current',425.00,'Review renewal requirements before expiration'),
('Insurance Record 07','Insurance','Health Department','2025-03-04','2026-03-04','Due Soon',500.00,'Review renewal requirements before expiration'),
('Certification Record 08','Certification','Insurance Carrier','2025-03-12','2026-04-11','Submitted',50.00,'Review renewal requirements before expiration'),
('License Record 09','License','City of Seattle','2025-03-20','2026-05-19','Renewed',125.00,'Review renewal requirements before expiration'),
('Permit Record 10','Permit','Washington State','2025-03-28','2026-03-28','Expired',200.00,'Review renewal requirements before expiration'),
('Insurance Record 11','Insurance','King County','2025-04-05','2026-05-05','Current',275.00,'Review renewal requirements before expiration'),
('Certification Record 12','Certification','Department of Revenue','2025-04-13','2026-06-12','Due Soon',350.00,'Review renewal requirements before expiration'),
('License Record 13','License','Labor and Industries','2025-04-21','2026-04-21','Submitted',425.00,'Review renewal requirements before expiration'),
('Permit Record 14','Permit','Fire Department','2025-04-29','2026-05-29','Renewed',500.00,'Review renewal requirements before expiration'),
('Insurance Record 15','Insurance','Health Department','2025-05-07','2026-07-06','Expired',50.00,'Review renewal requirements before expiration'),
('Certification Record 16','Certification','Insurance Carrier','2025-05-15','2026-05-15','Current',125.00,'Review renewal requirements before expiration'),
('License Record 17','License','City of Seattle','2025-05-23','2026-06-22','Due Soon',200.00,'Review renewal requirements before expiration'),
('Permit Record 18','Permit','Washington State','2025-05-31','2026-07-30','Submitted',275.00,'Review renewal requirements before expiration'),
('Insurance Record 19','Insurance','King County','2025-06-08','2026-06-08','Renewed',350.00,'Review renewal requirements before expiration'),
('Certification Record 20','Certification','Department of Revenue','2025-06-16','2026-07-16','Expired',425.00,'Review renewal requirements before expiration'),
('License Record 21','License','Labor and Industries','2025-06-24','2026-08-23','Current',500.00,'Review renewal requirements before expiration'),
('Permit Record 22','Permit','Fire Department','2025-07-02','2026-07-02','Due Soon',50.00,'Review renewal requirements before expiration'),
('Insurance Record 23','Insurance','Health Department','2025-07-10','2026-08-09','Submitted',125.00,'Review renewal requirements before expiration'),
('Certification Record 24','Certification','Insurance Carrier','2025-07-18','2026-09-16','Renewed',200.00,'Review renewal requirements before expiration'),
('License Record 25','License','City of Seattle','2025-07-26','2026-07-26','Expired',275.00,'Review renewal requirements before expiration'),
('Permit Record 26','Permit','Washington State','2025-08-03','2026-09-02','Current',350.00,'Review renewal requirements before expiration'),
('Insurance Record 27','Insurance','King County','2025-08-11','2026-10-10','Due Soon',425.00,'Review renewal requirements before expiration'),
('Certification Record 28','Certification','Department of Revenue','2025-08-19','2026-08-19','Submitted',500.00,'Review renewal requirements before expiration'),
('License Record 29','License','Labor and Industries','2025-08-27','2026-09-26','Renewed',50.00,'Review renewal requirements before expiration'),
('Permit Record 30','Permit','Fire Department','2025-09-04','2026-11-03','Expired',125.00,'Review renewal requirements before expiration'),
('Insurance Record 31','Insurance','Health Department','2025-09-12','2026-09-12','Current',200.00,'Review renewal requirements before expiration'),
('Certification Record 32','Certification','Insurance Carrier','2025-09-20','2026-10-20','Due Soon',275.00,'Review renewal requirements before expiration'),
('License Record 33','License','City of Seattle','2025-09-28','2026-11-27','Submitted',350.00,'Review renewal requirements before expiration'),
('Permit Record 34','Permit','Washington State','2025-10-06','2026-10-06','Renewed',425.00,'Review renewal requirements before expiration'),
('Insurance Record 35','Insurance','King County','2025-10-14','2026-11-13','Expired',500.00,'Review renewal requirements before expiration'),
('Certification Record 36','Certification','Department of Revenue','2025-10-22','2026-12-21','Current',50.00,'Review renewal requirements before expiration'),
('License Record 37','License','Labor and Industries','2025-10-30','2026-10-30','Due Soon',125.00,'Review renewal requirements before expiration'),
('Permit Record 38','Permit','Fire Department','2025-11-07','2026-12-07','Submitted',200.00,'Review renewal requirements before expiration'),
('Insurance Record 39','Insurance','Health Department','2025-11-15','2027-01-14','Renewed',275.00,'Review renewal requirements before expiration'),
('Certification Record 40','Certification','Insurance Carrier','2025-11-23','2026-11-23','Expired',350.00,'Review renewal requirements before expiration');

-- Verify sample row counts
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'vendors', COUNT(*) FROM vendors
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sales', COUNT(*) FROM sales
UNION ALL SELECT 'sales_line_items', COUNT(*) FROM sales_line_items
UNION ALL SELECT 'inventory_items', COUNT(*) FROM inventory_items
UNION ALL SELECT 'expenses', COUNT(*) FROM expenses
UNION ALL SELECT 'compliance_items', COUNT(*) FROM compliance_items;

-- Products that need to be reordered
SELECT
    p.product_id,
    p.product_name,
    i.stock_count,
    i.reorder_level,
    v.vendor_name
FROM inventory_items AS i
JOIN products AS p
    ON i.product_id = p.product_id
JOIN vendors AS v
    ON i.vendor_id = v.vendor_id
WHERE i.stock_count <= i.reorder_level
ORDER BY i.stock_count, p.product_name;

-- Customer order frequency and most recent order date
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.loyalty_points,
    COUNT(s.sale_id) AS order_count,
    MAX(s.sale_timestamp) AS last_order_date
FROM customers AS c
LEFT JOIN sales AS s
    ON c.customer_id = s.customer_id
GROUP BY c.customer_id, customer_name, c.loyalty_points
ORDER BY order_count DESC, customer_name;

-- Sales totals calculated from line items
SELECT
    s.sale_id,
    s.sale_timestamp,
    SUM(sli.quantity * sli.unit_price) AS sale_total
FROM sales AS s
JOIN sales_line_items AS sli
    ON s.sale_id = sli.sale_id
GROUP BY s.sale_id, s.sale_timestamp
ORDER BY s.sale_timestamp;

-- Upcoming compliance renewals
SELECT
    compliance_item_id,
    item_name,
    item_type,
    expiration_date,
    renewal_status,
    renewal_cost
FROM compliance_items
ORDER BY expiration_date;

SELECT * FROM customers;
SELECT * FROM expenses;

-- =========================================================
-- VIEW 1: CUSTOMER SALES SUMMARY
-- =========================================================

CREATE VIEW CustomerSalesSummary AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT s.sale_id) AS purchase_count,
    SUM(sli.quantity * sli.unit_price) AS total_spent,
    MAX(s.sale_timestamp) AS last_purchase
FROM customers AS c
JOIN sales AS s
    ON c.customer_id = s.customer_id
JOIN sales_line_items AS sli
    ON s.sale_id = sli.sale_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name;
    
-- =========================================================
-- VIEW 2: INVENTORY REORDER REPORT
-- =========================================================

CREATE VIEW InventoryReorderReport AS
SELECT
    p.product_id,
    p.product_name,
    v.vendor_name,
    i.stock_count,
    i.reorder_level
FROM inventory_items AS i
JOIN products AS p
    ON i.product_id = p.product_id
JOIN vendors AS v
    ON i.vendor_id = v.vendor_id
WHERE i.stock_count <= i.reorder_level;