-- Q3: Average stage durations for late and on-time orders.

WITH delivered_orders AS (
  SELECT
    SAFE_CAST(order_purchase_timestamp AS DATETIME) AS purchase_dt,
    SAFE_CAST(order_approved_at AS DATETIME) AS approved_dt,
    SAFE_CAST(order_delivered_carrier_date AS DATETIME) AS carrier_dt,
    SAFE_CAST(order_delivered_customer_date AS DATETIME) AS delivered_dt,
    SAFE_CAST(order_estimated_delivery_date AS DATETIME) AS estimated_dt
  FROM `olise-dataset-508614.olist_raw.orders`
  WHERE order_status = 'delivered'
)

SELECT
  CASE
    WHEN DATE(delivered_dt) > DATE(estimated_dt) THEN 'Late'
    ELSE 'On time'
  END AS delivery_group,

  COUNT(*) AS valid_stage_orders,

  AVG(
    DATETIME_DIFF(approved_dt, purchase_dt, SECOND) / 86400.0
  ) AS avg_approval_days,

  AVG(
    DATETIME_DIFF(carrier_dt, approved_dt, SECOND) / 86400.0
  ) AS avg_processing_days,

  AVG(
    DATETIME_DIFF(delivered_dt, carrier_dt, SECOND) / 86400.0
  ) AS avg_transit_days

FROM delivered_orders

WHERE purchase_dt IS NOT NULL
  AND approved_dt IS NOT NULL
  AND carrier_dt IS NOT NULL
  AND delivered_dt IS NOT NULL
  AND estimated_dt IS NOT NULL
  AND delivered_dt >= purchase_dt
  AND DATE(estimated_dt) >= DATE(purchase_dt)
  AND approved_dt >= purchase_dt
  AND carrier_dt >= approved_dt
  AND delivered_dt >= carrier_dt

GROUP BY delivery_group
ORDER BY delivery_group;
