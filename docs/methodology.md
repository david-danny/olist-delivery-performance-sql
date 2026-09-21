# Methodology

## Unit of analysis and eligibility

The base unit is one order. An eligible order has `order_status = 'delivered'`, valid purchase, customer delivery, and estimated delivery datetimes, actual delivery at or after purchase, and an estimated delivery date at or after the purchase date. `SAFE_CAST` converts source values to DATETIME. No conversion to Indonesian local time is applied.

Late orders have `DATE(delivered_dt) > DATE(estimated_dt)`. Delivery on the estimated calendar day counts as on time. Late rate is late orders divided by eligible orders. This measures timeliness against an estimate, not contractual SLA compliance.

All queries use the full source data and apply their eligibility filters. The resulting eligible purchase dates span September 15, 2016 to August 29, 2018. Months without eligible orders do not appear in Q1; absence does not mean a 0% late rate. September 2016 has only one eligible order. Boundary periods and small samples require caution.

## Joins

Q2 joins orders to customers using `customer_id`, not `customer_unique_id`. The order ID and customer ID keys must be unique in their respective tables to preserve one row per order.

Q4 groups raw reviews by order before joining. Q5 groups order items by order before joining. These steps prevent multi-item or multi-review orders from multiplying order counts.

## Stage durations (Q3)

Require purchase <= approval <= carrier handoff <= customer delivery, with all timestamps present. Durations use seconds divided by 86,400:

- Approval: purchase to approval.
- Processing: approval to carrier handoff.
- Transit: carrier handoff to customer delivery.

All three stage averages use the same 95,082 orders: 6,509 late and 88,573 on time. The 1,388 other eligible orders are excluded only from stage metrics. Processing time is not a direct measure of seller labor time.

## Reviews (Q4)

Keep only orders with exactly one raw review record, then require its score to be 1–5. Orders with multiple reviews are excluded from score metrics rather than selecting the latest review. Orders with no usable review remain in the eligibility denominator for coverage.

- Average score: mean of included review scores.
- Low review rate: scores 1–2 divided by included reviewed orders.
- Review coverage: included reviewed orders divided by eligible orders in the delivery group.
- Reviews before delivery: included reviews whose answer timestamp precedes actual delivery; this count includes all valid scores.

| Group | Eligible | Reviewed | Average score | Low review rate | Coverage | Reviews before delivery |
|---|---:|---:|---:|---:|---:|---:|
| Late | 6,534 | 6,353 | 2.27 | 62.36% | 97.23% | 4,450 |
| On time | 89,936 | 88,946 | 4.29 | 9.25% | 98.90% | 177 |

Reviews may be answered before receipt. Results are not restricted to post-delivery satisfaction. Timing alone does not establish why a customer gave a low score. Excluding multiple-review orders can affect the sample.

## Sellers (Q5)

An order must have exactly one distinct seller ID with no missing or empty seller IDs in its item rows. Multiple items from the same seller are allowed. Sellers must have at least 50 eligible single-seller orders; this is an analytical threshold, not a statistical guarantee.

The result includes 415 sellers and 71,598 eligible orders. The primary ranking is late order count, then late rate, order volume, and seller ID. Processing duration uses the complete chronological timeline filter described above. `valid_processing_orders` counts the orders used in that average; it is not a duration.

Delivery timestamps are recorded at order level. Region, time period, and other factors are not controlled in seller comparisons. The ranking identifies investigation priorities, not responsibility for delays.

## Dashboard aggregation and checks

For the overall late rate, use `SUM(late_orders) / SUM(eligible_orders)`, not the average of monthly rates. Store ratios as 0–1 values and display as Percent.

MAX can display an already calculated rate or mean only at its original unique group level (one state, delivery group, or seller). It is not an overall rate or mean. Disable summary rows for these metrics. Do not add orders across the five result sets; the same order can appear in several analyses.

| Check | Expected result |
|---|---:|
| Q1 output rows | 23 |
| Q2 output rows | 27 |
| Q1 and Q2 eligible order totals | 96,470 each |
| Q1 and Q2 late order totals | 6,534 each |
| Q3 output rows / valid orders | 2 / 95,082 |
| Q4 output rows | 2 |
| Q5 output rows / eligible orders | 415 / 71,598 |

No global date filter is used because the state, stage, review, and seller exports have no date column. Updated analysis requires exporting and importing the affected results again.
