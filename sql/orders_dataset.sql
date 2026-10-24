WITH single_seller_orders AS (
    SELECT i.order_id,
           MIN(i.seller_id) AS seller_id,
           COUNT(*) AS n_items,
           SUM(i.price) AS total_price,
           SUM(i.freight_value) AS total_freight,
           SUM(p.product_weight_g) AS total_weight_g,
           MIN(p.product_category_name) AS category
    FROM order_items i
    JOIN products p ON i.product_id = p.product_id
    GROUP BY i.order_id
    HAVING COUNT(DISTINCT i.seller_id) = 1
)
SELECT o.order_id,
       o.order_purchase_timestamp,
       c.customer_state,
       s.seller_state,
       x.n_items, x.total_price, x.total_freight, x.total_weight_g, x.category,
       CAST(strftime('%m', o.order_purchase_timestamp) AS INTEGER) AS month,
       CAST(strftime('%w', o.order_purchase_timestamp) AS INTEGER) AS weekday,
       JULIANDAY(o.order_estimated_delivery_date) - JULIANDAY(o.order_purchase_timestamp) AS estimated_days,
       CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END AS is_late
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN single_seller_orders x ON x.order_id = o.order_id
JOIN sellers s ON s.seller_id = x.seller_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND strftime('%Y-%m', o.order_purchase_timestamp) BETWEEN '2017-01' AND '2018-08'
ORDER BY o.order_purchase_timestamp;