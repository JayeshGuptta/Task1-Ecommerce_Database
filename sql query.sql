-- 1. USERS
CREATE TABLE Users (
    user_id         SERIAL PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    phone           VARCHAR(20),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. USER_ADDRESSES
CREATE TABLE User_Addresses (
    address_id      SERIAL PRIMARY KEY,
    user_id         INT NOT NULL,
    address_line1   VARCHAR(150) NOT NULL,
    address_line2   VARCHAR(150),
    city            VARCHAR(50)  NOT NULL,
    state           VARCHAR(50),
    postal_code     VARCHAR(20)  NOT NULL,
    country         VARCHAR(50)  NOT NULL,
    address_type    VARCHAR(10)  DEFAULT 'shipping' CHECK (address_type IN ('shipping','billing')),
    is_default      BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_address_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE
);

-- 3. CATEGORIES
CREATE TABLE Categories (
    category_id         SERIAL PRIMARY KEY,
    category_name       VARCHAR(100) NOT NULL,
    parent_category_id  INT,
    description         TEXT,

    CONSTRAINT fk_category_parent
        FOREIGN KEY (parent_category_id) REFERENCES Categories(category_id)
        ON DELETE SET NULL
);

-- 4. PRODUCTS
CREATE TABLE Products (
    product_id      SERIAL PRIMARY KEY,
    category_id     INT NOT NULL,
    product_name    VARCHAR(150) NOT NULL,
    description     TEXT,
    brand           VARCHAR(100),
    base_price      NUMERIC(10,2) NOT NULL CHECK (base_price >= 0),
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id) REFERENCES Categories(category_id)
        ON DELETE RESTRICT
);

-- 5. PRODUCT_VARIANTS 
CREATE TABLE Product_Variants (
    variant_id      SERIAL PRIMARY KEY,
    product_id      INT NOT NULL,
    sku             VARCHAR(50) NOT NULL UNIQUE,
    size            VARCHAR(20),
    color           VARCHAR(30),
    price           NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_variant_product
        FOREIGN KEY (product_id) REFERENCES Products(product_id)
        ON DELETE CASCADE
);

-- 6. ORDERS
CREATE TABLE Orders (
    order_id            SERIAL PRIMARY KEY,
    user_id             INT NOT NULL,
    shipping_address_id INT NOT NULL,
    order_date          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status              VARCHAR(20) DEFAULT 'pending'
                        CHECK (status IN ('pending','confirmed','shipped','delivered','cancelled')),
    total_amount        NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0),

    CONSTRAINT fk_order_user
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_address
        FOREIGN KEY (shipping_address_id) REFERENCES User_Addresses(address_id)
        ON DELETE RESTRICT
);

-- 7. ORDER_ITEMS
CREATE TABLE Order_Items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT NOT NULL,
    variant_id      INT NOT NULL,
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    subtotal        NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),

    CONSTRAINT fk_orderitem_order
        FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_orderitem_variant
        FOREIGN KEY (variant_id) REFERENCES Product_Variants(variant_id)
        ON DELETE RESTRICT
);

-- 8. INVENTORY (1-to-1 with variant)
CREATE TABLE Inventory (
    inventory_id        SERIAL PRIMARY KEY,
    variant_id          INT NOT NULL UNIQUE,
    quantity_available  INT NOT NULL DEFAULT 0 CHECK (quantity_available >= 0),
    warehouse_location  VARCHAR(100),
    last_updated        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_variant
        FOREIGN KEY (variant_id) REFERENCES Product_Variants(variant_id)
        ON DELETE CASCADE
);

-- USERS (8 records)
INSERT INTO Users (user_id, first_name, last_name, email, password_hash, phone) VALUES
(1, 'Ethan', 'Walker', 'ethan.walker@gmail.com', '$2b$12$Kx9vQzL1RmY7fH8pWeXjN0oT1sA2bC3dE4fG5hI6jK7lM8nO9', '+1-312-555-0148'),
(2, 'Sofia', 'Martinez', 'sofia.martinez@yahoo.com', '$2b$12$Kx9vQzL2RmY7fH8pWeXjN0oT1sA2bC3dE4fG5hI6jK7lM8nO9', '+1-702-555-0193'),
(3, 'Liam', 'Chen', 'liam.chen@outlook.com', '$2b$12$Kx9vQzL3RmY7fH8pWeXjN0oT1sA2bC3dE4fG5hI6jK7lM8nO9', '+1-415-555-0122'),
(4, 'Ava', 'Thompson', 'ava.thompson@gmail.com', '$2b$12$Kx9vQzL4RmY7fH8pWeXjN0oT1sA2bC3dE4fG5hI6jK7lM8nO9', '+1-206-555-0176'),
(5, 'Noah', 'Patel', 'noah.patel@gmail.com', '$2b$12$Kx9vQzL5RmY7fH8pWeXjN0oT1sA2bC3dE4fG5hI6jK7lM8nO9', '+1-732-555-0110'),
(6, 'Isabella', 'Garcia', 'isabella.garcia@hotmail.com', '$2b$12$Kx9vQzL6RmY7fH8pWeXjN0oT1sA2bC3dE4fG5hI6jK7lM8nO9', '+1-786-555-0164'),
(7, 'Mason', 'Kim', 'mason.kim@gmail.com', '$2b$12$Kx9vQzL7RmY7fH8pWeXjN0oT1sA2bC3dE4fG5hI6jK7lM8nO9', '+1-408-555-0187'),
(8, 'Olivia', 'Brown', 'olivia.brown@yahoo.com', '$2b$12$Kx9vQzL8RmY7fH8pWeXjN0oT1sA2bC3dE4fG5hI6jK7lM8nO9', '+1-617-555-0135');

-- USER_ADDRESSES (10 records)
INSERT INTO User_Addresses (address_id, user_id, address_line1, address_line2, city, state, postal_code, country, address_type, is_default) VALUES
(1, 1, '4517 Oakwood Drive', NULL, 'Chicago', 'IL', '60614', 'USA', 'shipping', True),
(2, 1, '220 W Adams St, Suite 900', NULL, 'Chicago', 'IL', '60606', 'USA', 'billing', False),
(3, 2, '8830 Desert Rose Lane', NULL, 'Las Vegas', 'NV', '89123', 'USA', 'shipping', True),
(4, 3, '1560 Mission Street, Apt 4B', NULL, 'San Francisco', 'CA', '94103', 'USA', 'shipping', True),
(5, 4, '725 Pine Street', 'Unit 12', 'Seattle', 'WA', '98101', 'USA', 'shipping', True),
(6, 5, '312 Raritan Avenue', NULL, 'Highland Park', 'NJ', '08904', 'USA', 'shipping', True),
(7, 6, '1901 Brickell Ave, Apt 2201', NULL, 'Miami', 'FL', '33129', 'USA', 'shipping', True),
(8, 7, '980 Stevens Creek Blvd', NULL, 'San Jose', 'CA', '95128', 'USA', 'shipping', True),
(9, 8, '45 Beacon Street', NULL, 'Boston', 'MA', '02108', 'USA', 'shipping', True),
(10, 2, '8830 Desert Rose Lane', NULL, 'Las Vegas', 'NV', '89123', 'USA', 'billing', False);

-- CATEGORIES (10 records)
INSERT INTO Categories (category_id, category_name, parent_category_id, description) VALUES
(1, 'Electronics', NULL, 'General consumer electronics and gadgets'),
(2, 'Mobile Phones', 1, 'Smartphones and accessories'),
(3, 'Laptops', 1, 'Laptops and notebook computers'),
(4, 'Clothing', NULL, 'Apparel for men and women'),
(5, 'Men''s Clothing', 4, 'Clothing items for men'),
(6, 'Women''s Clothing', 4, 'Clothing items for women'),
(7, 'Home & Kitchen', NULL, 'Home appliances and kitchen essentials'),
(8, 'Books', NULL, 'Fiction and non-fiction books'),
(9, 'Sports & Outdoors', NULL, 'Sporting goods and outdoor equipment'),
(10, 'Beauty & Personal Care', NULL, 'Skincare, haircare, and personal grooming');

-- PRODUCTS (40 records)
INSERT INTO Products (product_id, category_id, product_name, brand, base_price) VALUES
(1, 2, 'iPhone 15', 'Apple', 799.00),
(2, 2, 'iPhone 15 Pro', 'Apple', 999.00),
(3, 2, 'Galaxy S24', 'Samsung', 799.00),
(4, 2, 'Pixel 8', 'Google', 699.00),
(5, 2, 'OnePlus 12', 'OnePlus', 799.00),
(6, 3, 'MacBook Air M2', 'Apple', 1099.00),
(7, 3, 'XPS 13', 'Dell', 999.00),
(8, 3, 'Spectre x360', 'HP', 1399.00),
(9, 3, 'ThinkPad X1 Carbon', 'Lenovo', 1499.00),
(10, 3, 'ROG Zephyrus G14', 'Asus', 1799.00),
(11, 1, 'WH-1000XM5 Headphones', 'Sony', 399.00),
(12, 1, 'Apple Watch Series 9', 'Apple', 399.00),
(13, 1, 'iPad Air', 'Apple', 599.00),
(14, 1, 'Echo Dot (5th Gen)', 'Amazon', 49.99),
(15, 1, 'Flip 6 Bluetooth Speaker', 'JBL', 129.95),
(16, 5, '501 Original Fit Jeans', 'Levi''s', 69.50),
(17, 5, 'Dri-FIT Crew T-Shirt', 'Nike', 30.00),
(18, 5, 'Track Jacket', 'Adidas', 65.00),
(19, 5, 'Classic Fit Polo Shirt', 'Ralph Lauren', 89.50),
(20, 6, 'Floral Wrap Midi Dress', 'Zara', 59.90),
(21, 6, 'Oversized Denim Jacket', 'H&M', 49.99),
(22, 6, '711 Skinny Jeans', 'Levi''s', 69.50),
(23, 6, 'One Luxe Leggings', 'Nike', 55.00),
(24, 7, 'Duo 7-in-1 Electric Pressure Cooker', 'Instant Pot', 99.95),
(25, 7, 'Professional Plus Blender', 'Ninja', 89.99),
(26, 7, 'V11 Cordless Vacuum', 'Dyson', 599.00),
(27, 7, 'Artisan Stand Mixer', 'KitchenAid', 429.99),
(28, 7, 'Air Fryer XXL', 'Philips', 149.99),
(29, 7, '12-Cup Programmable Coffee Maker', 'Cuisinart', 79.95),
(30, 8, 'Atomic Habits', 'Penguin Random House', 16.99),
(31, 8, 'The Psychology of Money', 'Harriman House', 18.99),
(32, 8, 'Sapiens: A Brief History of Humankind', 'Harper', 21.99),
(33, 8, 'Rich Dad Poor Dad', 'Plata Publishing', 14.99),
(34, 8, 'The Alchemist', 'HarperOne', 13.99),
(35, 9, 'Evolution Basketball', 'Wilson', 29.99),
(36, 9, 'Extra Thick Yoga Mat', 'Gaiam', 25.99),
(37, 9, 'Charge 6 Fitness Tracker', 'Fitbit', 159.95),
(38, 9, '32 oz Wide Mouth Water Bottle', 'Hydro Flask', 44.95),
(39, 10, 'Moisturizing Cream', 'CeraVe', 16.99),
(40, 10, 'Ultra Sheer Dry-Touch Sunscreen SPF 55', 'Neutrogena', 11.99);

-- PRODUCT_VARIANTS (74 records)
INSERT INTO Product_Variants (variant_id, product_id, sku, size, color, price) VALUES
(1, 1, 'SKU-001-0001', NULL, 'Black', 799.00),
(2, 1, 'SKU-001-0002', NULL, 'Blue', 799.00),
(3, 2, 'SKU-002-0003', NULL, 'Natural Titanium', 999.00),
(4, 2, 'SKU-002-0004', NULL, 'Blue Titanium', 999.00),
(5, 3, 'SKU-003-0005', NULL, 'Onyx Black', 799.00),
(6, 3, 'SKU-003-0006', NULL, 'Marble Gray', 799.00),
(7, 4, 'SKU-004-0007', NULL, 'Obsidian', 699.00),
(8, 4, 'SKU-004-0008', NULL, 'Hazel', 699.00),
(9, 5, 'SKU-005-0009', NULL, 'Flowy Emerald', 799.00),
(10, 5, 'SKU-005-0010', NULL, 'Silky Black', 799.00),
(11, 6, 'SKU-006-0011', NULL, 'Space Gray', 1099.00),
(12, 6, 'SKU-006-0012', NULL, 'Silver', 1099.00),
(13, 7, 'SKU-007-0013', NULL, 'Platinum Silver', 999.00),
(14, 7, 'SKU-007-0014', NULL, 'Graphite', 999.00),
(15, 8, 'SKU-008-0015', NULL, 'Nightfall Black', 1399.00),
(16, 8, 'SKU-008-0016', NULL, 'Nocturne Blue', 1399.00),
(17, 9, 'SKU-009-0017', NULL, 'Black', 1499.00),
(18, 9, 'SKU-009-0018', NULL, 'Carbon Fiber Weave', 1549.00),
(19, 10, 'SKU-010-0019', NULL, 'Eclipse Gray', 1799.00),
(20, 10, 'SKU-010-0020', NULL, 'Moonlight White', 1799.00),
(21, 11, 'SKU-011-0021', NULL, 'Black', 399.00),
(22, 11, 'SKU-011-0022', NULL, 'Silver', 399.00),
(23, 12, 'SKU-012-0023', '41mm', NULL, 399.00),
(24, 12, 'SKU-012-0024', '45mm', NULL, 429.00),
(25, 13, 'SKU-013-0025', NULL, 'Space Gray', 599.00),
(26, 13, 'SKU-013-0026', NULL, 'Starlight', 599.00),
(27, 14, 'SKU-014-0027', NULL, 'Charcoal', 49.99),
(28, 15, 'SKU-015-0028', NULL, 'Black', 129.95),
(29, 15, 'SKU-015-0029', NULL, 'Blue', 129.95),
(30, 16, 'SKU-016-0030', 'S', 'Standard', 69.50),
(31, 16, 'SKU-016-0031', 'M', 'Standard', 69.50),
(32, 16, 'SKU-016-0032', 'L', 'Standard', 69.50),
(33, 17, 'SKU-017-0033', 'S', 'Standard', 30.00),
(34, 17, 'SKU-017-0034', 'M', 'Standard', 30.00),
(35, 17, 'SKU-017-0035', 'L', 'Standard', 30.00),
(36, 18, 'SKU-018-0036', 'S', 'Standard', 65.00),
(37, 18, 'SKU-018-0037', 'M', 'Standard', 65.00),
(38, 18, 'SKU-018-0038', 'L', 'Standard', 65.00),
(39, 19, 'SKU-019-0039', 'S', 'Standard', 89.50),
(40, 19, 'SKU-019-0040', 'M', 'Standard', 89.50),
(41, 19, 'SKU-019-0041', 'L', 'Standard', 89.50),
(42, 20, 'SKU-020-0042', 'S', 'Standard', 59.90),
(43, 20, 'SKU-020-0043', 'M', 'Standard', 59.90),
(44, 20, 'SKU-020-0044', 'L', 'Standard', 59.90),
(45, 21, 'SKU-021-0045', 'S', 'Standard', 49.99),
(46, 21, 'SKU-021-0046', 'M', 'Standard', 49.99),
(47, 21, 'SKU-021-0047', 'L', 'Standard', 49.99),
(48, 22, 'SKU-022-0048', 'S', 'Standard', 69.50),
(49, 22, 'SKU-022-0049', 'M', 'Standard', 69.50),
(50, 22, 'SKU-022-0050', 'L', 'Standard', 69.50),
(51, 23, 'SKU-023-0051', 'S', 'Standard', 55.00),
(52, 23, 'SKU-023-0052', 'M', 'Standard', 55.00),
(53, 23, 'SKU-023-0053', 'L', 'Standard', 55.00),
(54, 24, 'SKU-024-0054', NULL, 'Stainless Steel', 99.95),
(55, 25, 'SKU-025-0055', NULL, 'Black', 89.99),
(56, 26, 'SKU-026-0056', NULL, 'Nickel/Red', 599.00),
(57, 27, 'SKU-027-0057', NULL, 'Empire Red', 429.99),
(58, 27, 'SKU-027-0058', NULL, 'White', 429.99),
(59, 28, 'SKU-028-0059', NULL, 'Black', 149.99),
(60, 29, 'SKU-029-0060', NULL, 'Stainless Steel', 79.95),
(61, 30, 'SKU-030-0061', 'Paperback', NULL, 16.99),
(62, 31, 'SKU-031-0062', 'Paperback', NULL, 18.99),
(63, 32, 'SKU-032-0063', 'Paperback', NULL, 21.99),
(64, 33, 'SKU-033-0064', 'Paperback', NULL, 14.99),
(65, 34, 'SKU-034-0065', 'Paperback', NULL, 13.99),
(66, 35, 'SKU-035-0066', 'Size 7', NULL, 29.99),
(67, 36, 'SKU-036-0067', NULL, 'Purple', 25.99),
(68, 36, 'SKU-036-0068', NULL, 'Teal', 25.99),
(69, 37, 'SKU-037-0069', NULL, 'Black', 159.95),
(70, 37, 'SKU-037-0070', NULL, 'Coral', 159.95),
(71, 38, 'SKU-038-0071', NULL, 'Black', 44.95),
(72, 38, 'SKU-038-0072', NULL, 'Stone', 44.95),
(73, 39, 'SKU-039-0073', NULL, '16 oz Jar', 16.99),
(74, 40, 'SKU-040-0074', NULL, '3 oz Tube', 11.99);

-- INVENTORY (74 records)
INSERT INTO Inventory (variant_id, quantity_available, warehouse_location) VALUES
(1, 12, 'Reno DC - Aisle 2'),
(2, 0, 'Newark DC - Aisle 7'),
(3, 55, 'Dallas DC - Aisle 1'),
(4, 40, 'Chicago DC - Aisle 4'),
(5, 40, 'Reno DC - Aisle 2'),
(6, 25, 'Newark DC - Aisle 7'),
(7, 12, 'Dallas DC - Aisle 1'),
(8, 100, 'Chicago DC - Aisle 4'),
(9, 12, 'Reno DC - Aisle 2'),
(10, 150, 'Newark DC - Aisle 7'),
(11, 75, 'Dallas DC - Aisle 1'),
(12, 0, 'Chicago DC - Aisle 4'),
(13, 0, 'Reno DC - Aisle 2'),
(14, 12, 'Newark DC - Aisle 7'),
(15, 40, 'Dallas DC - Aisle 1'),
(16, 40, 'Chicago DC - Aisle 4'),
(17, 100, 'Reno DC - Aisle 2'),
(18, 150, 'Newark DC - Aisle 7'),
(19, 0, 'Dallas DC - Aisle 1'),
(20, 100, 'Chicago DC - Aisle 4'),
(21, 40, 'Reno DC - Aisle 2'),
(22, 100, 'Newark DC - Aisle 7'),
(23, 75, 'Dallas DC - Aisle 1'),
(24, 40, 'Chicago DC - Aisle 4'),
(25, 90, 'Reno DC - Aisle 2'),
(26, 150, 'Newark DC - Aisle 7'),
(27, 55, 'Dallas DC - Aisle 1'),
(28, 0, 'Chicago DC - Aisle 4'),
(29, 25, 'Reno DC - Aisle 2'),
(30, 75, 'Newark DC - Aisle 7'),
(31, 60, 'Dallas DC - Aisle 1'),
(32, 55, 'Chicago DC - Aisle 4'),
(33, 25, 'Reno DC - Aisle 2'),
(34, 40, 'Newark DC - Aisle 7'),
(35, 60, 'Dallas DC - Aisle 1'),
(36, 12, 'Chicago DC - Aisle 4'),
(37, 12, 'Reno DC - Aisle 2'),
(38, 75, 'Newark DC - Aisle 7'),
(39, 12, 'Dallas DC - Aisle 1'),
(40, 60, 'Chicago DC - Aisle 4'),
(41, 60, 'Reno DC - Aisle 2'),
(42, 150, 'Newark DC - Aisle 7'),
(43, 55, 'Dallas DC - Aisle 1'),
(44, 0, 'Chicago DC - Aisle 4'),
(45, 90, 'Reno DC - Aisle 2'),
(46, 100, 'Newark DC - Aisle 7'),
(47, 12, 'Dallas DC - Aisle 1'),
(48, 75, 'Chicago DC - Aisle 4'),
(49, 12, 'Reno DC - Aisle 2'),
(50, 100, 'Newark DC - Aisle 7'),
(51, 55, 'Dallas DC - Aisle 1'),
(52, 150, 'Chicago DC - Aisle 4'),
(53, 60, 'Reno DC - Aisle 2'),
(54, 150, 'Newark DC - Aisle 7'),
(55, 40, 'Dallas DC - Aisle 1'),
(56, 12, 'Chicago DC - Aisle 4'),
(57, 0, 'Reno DC - Aisle 2'),
(58, 40, 'Newark DC - Aisle 7'),
(59, 55, 'Dallas DC - Aisle 1'),
(60, 12, 'Chicago DC - Aisle 4'),
(61, 40, 'Reno DC - Aisle 2'),
(62, 12, 'Newark DC - Aisle 7'),
(63, 75, 'Dallas DC - Aisle 1'),
(64, 55, 'Chicago DC - Aisle 4'),
(65, 90, 'Reno DC - Aisle 2'),
(66, 60, 'Newark DC - Aisle 7'),
(67, 25, 'Dallas DC - Aisle 1'),
(68, 60, 'Chicago DC - Aisle 4'),
(69, 60, 'Reno DC - Aisle 2'),
(70, 40, 'Newark DC - Aisle 7'),
(71, 55, 'Dallas DC - Aisle 1'),
(72, 12, 'Chicago DC - Aisle 4'),
(73, 150, 'Reno DC - Aisle 2'),
(74, 25, 'Newark DC - Aisle 7');

-- ORDERS (15 records)
INSERT INTO Orders (order_id, user_id, shipping_address_id, order_date, status, total_amount) VALUES
(1, 1, 1, CURRENT_TIMESTAMP - INTERVAL '45 days', 'delivered', 898.98),
(2, 2, 3, CURRENT_TIMESTAMP - INTERVAL '40 days', 'delivered', 1099.00),
(3, 3, 4, CURRENT_TIMESTAMP - INTERVAL '38 days', 'delivered', 1197.00),
(4, 4, 5, CURRENT_TIMESTAMP - INTERVAL '20 days', 'shipped', 799.00),
(5, 5, 6, CURRENT_TIMESTAMP - INTERVAL '33 days', 'delivered', 238.90),
(6, 6, 7, CURRENT_TIMESTAMP - INTERVAL '30 days', 'cancelled', 799.00),
(7, 7, 8, CURRENT_TIMESTAMP - INTERVAL '25 days', 'delivered', 30.00),
(8, 8, 9, CURRENT_TIMESTAMP - INTERVAL '5 days', 'confirmed', 1028.99),
(9, 1, 2, CURRENT_TIMESTAMP - INTERVAL '18 days', 'delivered', 999.00),
(10, 2, 10, CURRENT_TIMESTAMP - INTERVAL '8 days', 'shipped', 239.85),
(11, 3, 4, CURRENT_TIMESTAMP - INTERVAL '1 days', 'pending', 999.00),
(12, 4, 5, CURRENT_TIMESTAMP - INTERVAL '15 days', 'delivered', 28.98),
(13, 5, 6, CURRENT_TIMESTAMP - INTERVAL '12 days', 'delivered', 319.90),
(14, 6, 7, CURRENT_TIMESTAMP - INTERVAL '3 days', 'confirmed', 129.95),
(15, 8, 9, CURRENT_TIMESTAMP - INTERVAL '22 days', 'delivered', 61.94);

-- ORDER_ITEMS
INSERT INTO Order_Items (order_id, variant_id, quantity, unit_price, subtotal) VALUES
(1, 1, 1, 799.00, 799.00),
(1, 46, 2, 49.99, 99.98),
(2, 11, 1, 1099.00, 1099.00),
(3, 21, 1, 399.00, 399.00),
(3, 23, 2, 399.00, 798.00),
(4, 2, 1, 799.00, 799.00),
(5, 41, 2, 89.50, 179.00),
(5, 44, 1, 59.90, 59.90),
(6, 9, 1, 799.00, 799.00),
(7, 33, 1, 30.00, 30.00),
(8, 56, 1, 599.00, 599.00),
(8, 58, 1, 429.99, 429.99),
(9, 13, 1, 999.00, 999.00),
(10, 60, 3, 79.95, 239.85),
(11, 3, 1, 999.00, 999.00),
(12, 64, 1, 14.99, 14.99),
(12, 65, 1, 13.99, 13.99),
(13, 70, 2, 159.95, 319.90),
(14, 29, 1, 129.95, 129.95),
(15, 72, 1, 44.95, 44.95),
(15, 73, 1, 16.99, 16.99);

SELECT * FROM categories;
SELECT * FROM inventory;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM product_variants;
SELECT * FROM products;
SELECT * FROM user_addresses;
SELECT * FROM users;