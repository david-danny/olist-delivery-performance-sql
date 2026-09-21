-- Q1: Late delivery rate by purchase month.

WITH delivered_orders AS (
  SELECT
    SAFE_CAST(order_purchase_timestamp AS DATETIME) AS purchase_dt,
    SAFE_CAST(order_delivered_customer_date AS DATETIME) AS delivered_dt,
    SAFE_CAST(order_estimated_delivery_date AS DATETIME) AS estimated_dt
  FROM `olise-dataset-508614.olist_raw.orders`
  WHERE order_status = 'delivered'
)

SELECT
  DATE_TRUNC(DATE(purchase_dt), MONTH) AS purchase_month,
  COUNT(*) AS eligible_orders,
  COUNTIF(DATE(delivered_dt) > DATE(estimated_dt)) AS late_orders,
  SAFE_DIVIDE(
    COUNTIF(DATE(delivered_dt) > DATE(estimated_dt)),
    COUNT(*)
  ) AS late_delivery_rate
FROM delivered_orders
WHERE purchase_dt IS NOT NULL
  AND delivered_dt IS NOT NULL
  AND estimated_dt IS NOT NULL
  AND delivered_dt >= purchase_dt
  AND DATE(estimated_dt) >= DATE(purchase_dt)
GROUP BY purchase_month
ORDER BY purchase_month;
