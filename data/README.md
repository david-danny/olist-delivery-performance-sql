# Data setup and reproduction

Download and extract the [Olist dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). These five analyses use four raw tables:

| CSV | BigQuery table | Used by |
|---|---|---|
| olist_orders_dataset.csv | olist_raw.orders | Q1–Q5 |
| olist_customers_dataset.csv | olist_raw.customers | Q2 |
| olist_order_reviews_dataset.csv | olist_raw.order_reviews | Q4 |
| olist_order_items_dataset.csv | olist_raw.order_items | Q5 |

1. Create a dataset named `olist_raw` in your BigQuery project.
2. Upload each CSV using its original column names and the table names above. The project used STRING columns for the raw imports; the queries cast dates and review scores explicitly. For that setup, define one STRING field per CSV header in the original order, skip one header row, and keep the import error tolerance at zero. Enable **Allow quoted newlines** for reviews.
3. Verify that `orders.order_id` and `customers.customer_id` are unique and non-null. Check uniqueness of `(order_id, order_item_id)` in items, inspect unmatched order/customer keys, and review failed nonblank date casts. Multiple review rows per order are handled explicitly by Q4.
4. The SQL files contain project ID `olise-dataset-508614`. Replace that ID with your own if running in another project. Keep the `olist_raw` dataset name or update the paths consistently.
5. Run each complete Q1–Q5 file separately. Each contains its own CTEs and final SELECT. No analytical view or earlier advanced SQL package is required.
6. Export the full results as CSV, preserving headers and numeric precision. Use the mapping below for Google Sheets.
7. Connect each worksheet as a separate Looker Studio source. Compare results with the checks in [methodology](../docs/methodology.md).

| SQL file | CSV export name | Sheets tab |
|---|---|---|
| q1_monthly_delivery_basic.sql | q1_monthly.csv | monthly |
| q2_state_delivery_basic.sql | q2_states.csv | states |
| q3_delivery_stages_basic.sql | q3_stages.csv | stages |
| q4_reviews_basic.sql | q4_reviews.csv | reviews |
| q5_seller_priority_basic.sql | q5_sellers.csv | sellers |

Export all 415 seller rows, even if the dashboard displays 10 or 20 at once. Raw CSV files are not bundled here; obtain them from the original source. Keep your own exported results as a reproducibility snapshot.
