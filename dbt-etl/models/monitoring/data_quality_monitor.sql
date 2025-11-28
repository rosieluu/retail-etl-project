-- data_quality_monitor.sql
-- Table simple de monitoring consolidant tous les problèmes de qualité

{{ config(
    materialized='table',
    tags=['monitoring']
) }}

-- Consolidation de tous les tests de qualité
SELECT
    'dim_product' as table_name,
    'low_price' as issue_type,
    product_id as record_id,
    CONCAT('Prix: ', CAST(price as STRING)) as details,
    CURRENT_TIMESTAMP() as checked_at
FROM {{ ref('dim_product') }}
WHERE price < 0.10

UNION ALL

SELECT
    'dim_product',
    'missing_description',
    product_id,
    CONCAT('StockCode: ', stock_code) as details,
    CURRENT_TIMESTAMP()
FROM {{ ref('dim_product') }}
WHERE description IS NULL OR TRIM(description) = ''

UNION ALL

SELECT
    'dim_customer',
    'missing_iso',
    customer_id,
    CONCAT('Country: ', country) as details,
    CURRENT_TIMESTAMP()
FROM {{ ref('dim_customer') }}
WHERE iso IS NULL

UNION ALL

SELECT
    'dim_datetime',
    'future_date',
    datetime_id,
    CAST(datetime as STRING) as details,
    CURRENT_TIMESTAMP()
FROM {{ ref('dim_datetime') }}
WHERE datetime > CURRENT_DATETIME()

UNION ALL

SELECT
    'fct_invoices',
    'high_quantity',
    CONCAT(invoice_id, '-', product_id),
    CONCAT('Qty: ', CAST(quantity as STRING)) as details,
    CURRENT_TIMESTAMP()
FROM {{ ref('fct_invoices') }}
WHERE quantity > 1000

UNION ALL

SELECT
    'fct_invoices',
    'high_total',
    CONCAT(invoice_id, '-', product_id),
    CONCAT('Total: ', CAST(total as STRING)) as details,
    CURRENT_TIMESTAMP()
FROM {{ ref('fct_invoices') }}
WHERE total > 10000