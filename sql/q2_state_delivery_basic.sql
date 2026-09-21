-- Q2: Destination states ranked by late order count.


WITH delivered_orders AS (
  SELECT
    customer_id,
    SAFE_CAST(order_purchase_timestamp AS DATETIME) AS purchase_dt,
    SAFE_CAST(order_delivered_customer_date AS DATETIME) AS delivered_dt,
    SAFE_CAST(order_estimated_delivery_date AS DATETIME) AS estimated_dt
  FROM `olise-dataset-508614.olist_raw.orders`
  WHERE order_status = 'delivered'
)

SELECT
  c.customer_state,
  COUNT(*) AS eligible_orders,
  COUNTIF(DATE(o.delivered_dt) > DATE(o.estimated_dt)) AS late_orders,
  SAFE_DIVIDE(
    COUNTIF(DATE(o.delivered_dt) > DATE(o.estimated_dt)),
    COUNT(*)
  ) AS late_delivery_rate

FROM delivered_orders AS o
LEFT JOIN `olise-dataset-508614.olist_raw.customers` AS c
  ON o.customer_id = c.customer_id

WHERE o.purchase_dt IS NOT NULL
  AND o.delivered_dt IS NOT NULL
  AND o.estimated_dt IS NOT NULL
  AND o.delivered_dt >= o.purchase_dt
  AND DATE(o.estimated_dt) >= DATE(o.purchase_dt)

GROUP BY c.customer_state
ORDER BY late_orders DESC, eligible_orders DESC, c.customer_state;
