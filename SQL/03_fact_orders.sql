CREATE OR REPLACE VIEW `Olist.fact_orders_cleaned` AS
SELECT 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
-- Handling missing delivery dates: If actual delivery date is null, use estimated delivery date.
-- This ensures we don't lose data for the 'delivered' orders identified during validation.
    COALESCE(order_delivered_customer_date, order_estimated_delivery_date) AS           order_delivered_customer_date_final,
-- Flagging the data quality: Distinguishing between actual and estimated delivery dates.
    CASE 
        WHEN order_delivered_customer_date IS NULL AND order_status = 'delivered' THEN 'Estimated' 
        WHEN order_delivered_customer_date IS NOT NULL THEN 'Actual'
        ELSE 'Not Delivered'
    END AS delivery_date_type,
    order_estimated_delivery_date
FROM `Olist.olist_orders`;