-- Q4: Review scores by delivery group.

WITH delivered_orders AS (
  SELECT
    order_id,
    SAFE_CAST(order_purchase_timestamp AS DATETIME) AS purchase_dt,
    SAFE_CAST(order_delivered_customer_date AS DATETIME) AS delivered_dt,
    SAFE_CAST(order_estimated_delivery_date AS DATETIME) AS estimated_dt
  FROM `olise-dataset-508614.olist_raw.orders`
  WHERE order_status = 'delivered'
),

single_review_orders AS (
  SELECT
    order_id,
    MAX(SAFE_CAST(review_score AS INT64)) AS review_score,
    MAX(SAFE_CAST(review_answer_timestamp AS DATETIME)) AS review_answer_dt
  FROM `olise-dataset-508614.olist_raw.order_reviews`
  GROUP BY order_id
  HAVING COUNT(*) = 1
    AND review_score BETWEEN 1 AND 5
)

SELECT
  CASE
    WHEN DATE(o.delivered_dt) > DATE(o.estimated_dt) THEN 'Late'
    ELSE 'On time'
  END AS delivery_group,

  COUNT(*) AS eligible_orders,
  COUNT(r.review_score) AS reviewed_orders,
  AVG(r.review_score) AS avg_review_score,

  SAFE_DIVIDE(
    COUNTIF(r.review_score IN (1, 2)),
    COUNT(r.review_score)
  ) AS low_review_rate,

  SAFE_DIVIDE(
    COUNT(r.review_score),
    COUNT(*)
  ) AS review_coverage,

  COUNTIF(
    r.review_answer_dt < o.delivered_dt
  ) AS reviews_before_delivery

FROM delivered_orders AS o
LEFT JOIN single_review_orders AS r
  ON o.order_id = r.order_id

WHERE o.purchase_dt IS NOT NULL
  AND o.delivered_dt IS NOT NULL
  AND o.estimated_dt IS NOT NULL
  AND o.delivered_dt >= o.purchase_dt
  AND DATE(o.estimated_dt) >= DATE(o.purchase_dt)

GROUP BY delivery_group
ORDER BY delivery_group;
