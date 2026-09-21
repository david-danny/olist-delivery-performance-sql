-- Q5: Seller priorities by late order count.
-- Single-seller orders only, minimum 50 eligible orders per seller.

WITH delivered_orders AS (
  SELECT
    order_id,
    SAFE_CAST(order_purchase_timestamp AS DATETIME) AS purchase_dt,
    SAFE_CAST(order_approved_at AS DATETIME) AS approved_dt,
    SAFE_CAST(order_delivered_carrier_date AS DATETIME) AS carrier_dt,
    SAFE_CAST(order_delivered_customer_date AS DATETIME) AS delivered_dt,
    SAFE_CAST(order_estimated_delivery_date AS DATETIME) AS estimated_dt
  FROM `olise-dataset-508614.olist_raw.orders`
  WHERE order_status = 'delivered'
),

single_seller_orders AS (
  SELECT
    i.order_id,
    MIN(i.seller_id) AS seller_id
  FROM `olise-dataset-508614.olist_raw.order_items` AS i
  GROUP BY i.order_id
  HAVING COUNT(DISTINCT i.seller_id) = 1
    AND COUNTIF(i.seller_id IS NULL OR i.seller_id = '') = 0
)

SELECT
  s.seller_id,
  COUNT(*) AS eligible_orders,
  COUNTIF(DATE(o.delivered_dt) > DATE(o.estimated_dt)) AS late_orders,

  SAFE_DIVIDE(
    COUNTIF(DATE(o.delivered_dt) > DATE(o.estimated_dt)),
    COUNT(*)
  ) AS late_delivery_rate,

  COUNTIF(
    o.approved_dt >= o.purchase_dt
    AND o.carrier_dt >= o.approved_dt
    AND o.delivered_dt >= o.carrier_dt
  ) AS valid_processing_orders,

  AVG(
    CASE
      WHEN o.approved_dt >= o.purchase_dt
        AND o.carrier_dt >= o.approved_dt
        AND o.delivered_dt >= o.carrier_dt
      THEN DATETIME_DIFF(o.carrier_dt, o.approved_dt, SECOND) / 86400.0
      ELSE NULL
    END
  ) AS avg_processing_days

FROM delivered_orders AS o
INNER JOIN single_seller_orders AS s
  ON o.order_id = s.order_id

WHERE o.purchase_dt IS NOT NULL
  AND o.delivered_dt IS NOT NULL
  AND o.estimated_dt IS NOT NULL
  AND o.delivered_dt >= o.purchase_dt
  AND DATE(o.estimated_dt) >= DATE(o.purchase_dt)

GROUP BY s.seller_id
HAVING COUNT(*) >= 50

ORDER BY
  late_orders DESC,
  late_delivery_rate DESC,
  eligible_orders DESC,
  s.seller_id;
