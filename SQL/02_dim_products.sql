CREATE OR REPLACE VIEW `Olist.dim_products_translated` AS
SELECT  products.product_id,
        COALESCE(translation.product_category_name_english, 'other') as product_category_name,
        products.product_name_lenght AS product_name_length,
        products.product_description_lenght AS product_description_length,
        products.product_photos_qty,
        products.product_weight_g,
        products.product_length_cm,
        products.product_height_cm,
        products.product_width_cm
FROM `Olist.olist_products` products
LEFT JOIN `Olist.product_category_name_translation` translation
ON products.product_category_name = translation.product_category_name