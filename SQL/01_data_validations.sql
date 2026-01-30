-- 1. PRIMARY KEY VALIDATION
-- Goal: Ensure 'order_id' is unique.
-- Result: 0 duplicates confirmed.
SELECT order_id, COUNT(*)
FROM `Olist.olist_orders`
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 2. COMPLETENESS CHECK: Price Validation
-- Goal: Identify missing or zero prices in order items.
-- Result: All items have valid price data.
SELECT *
FROM `Olist.olist_order_items`
WHERE price is null or price = 0;

-- 3. NULL VALUE CHECK: Customer Mapping
-- Goal: Check for orders without a linked customer_id.
-- Result: 0 nulls found. Every order is correctly mapped to a customer.
SELECT customer_id as empty_id
FROM `Olist.olist_orders`
WHERE customer_id is null;

-- 4. DATA VOLUME AUDIT
-- Goal: Reconcile total rows vs unique IDs to confirm table grain.
-- Result: Counts match exactly, confirming one record per entity.
SELECT COUNT(order_id) AS total_rows, 
       COUNT(DISTINCT order_id) AS unique_orders 
FROM `Olist.olist_orders`;

SELECT COUNT(product_id) AS total_rows, 
       COUNT(DISTINCT product_id) AS unique_products 
FROM `Olist.olist_products`;

-- 5. REFERENTIAL INTEGRITY CHECK: Identifying 'Orphan' items
-- Goal: Verify that every record in 'order_items' has a corresponding record in the 'orders' table.
-- Result: 0 orphan records found.
SELECT orders.order_id as orphan_id
FROM `Olist.olist_order_items` order_items
LEFT JOIN `Olist.olist_orders` orders
ON order_items.order_id = orders.order_id
WHERE orders.order_id is null;

SELECT order_items.order_id as orphan_id
FROM `Olist.olist_order_items` order_items
LEFT JOIN `Olist.olist_orders` orders
ON order_items.order_id = orders.order_id
WHERE order_items.order_id is null;


-- 6. BUSINESS LOGIC AUDIT: Revenue in canceled orders
-- Finding: Canceled orders still contain price data. 
-- Note: Must filter status in Power BI to ensure 'Total Revenue' only includes successful sales.
SELECT orders.order_id, orders.order_status, order_items.price
FROM `Olist.olist_orders` orders
LEFT JOIN `Olist.olist_order_items` order_items ON orders.order_id = order_items.order_id
WHERE order_status = 'canceled' AND price > 0;

-- 7. ANOMALY DETECTION: Delivered orders without delivery timestamps
-- Finding: 8 orders marked as 'delivered' are missing a customer delivery date.
-- Action: Handled in the final View using COALESCE with the estimated delivery date.
SELECT *
FROM `Olist.olist_orders`
WHERE order_status = 'delivered' and order_delivered_customer_date is null;
