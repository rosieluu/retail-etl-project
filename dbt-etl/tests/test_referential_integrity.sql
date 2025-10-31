-- Test d'intégrité référentielle avancé
-- Vérifie que toutes les clés étrangères dans fct_invoices existent dans leurs dimensions respectives

-- Test 1: Vérifier que tous les customer_id existent dans dim_customer
WITH missing_customers AS (
    SELECT DISTINCT fi.customer_id
    FROM {{ ref('fct_invoices') }} fi
    LEFT JOIN {{ ref('dim_customer') }} dc ON fi.customer_id = dc.customer_id
    WHERE dc.customer_id IS NULL
),

-- Test 2: Vérifier que tous les product_id existent dans dim_product
missing_products AS (
    SELECT DISTINCT fi.product_id
    FROM {{ ref('fct_invoices') }} fi
    LEFT JOIN {{ ref('dim_product') }} dp ON fi.product_id = dp.product_id
    WHERE dp.product_id IS NULL
),

-- Test 3: Vérifier que tous les datetime_id existent dans dim_datetime
missing_datetimes AS (
    SELECT DISTINCT fi.datetime_id
    FROM {{ ref('fct_invoices') }} fi
    LEFT JOIN {{ ref('dim_datetime') }} dd ON fi.datetime_id = dd.datetime_id
    WHERE dd.datetime_id IS NULL
)

-- Combiner tous les résultats - devrait être vide si l'intégrité est respectée
SELECT 'missing_customer' as error_type, customer_id as missing_key
FROM missing_customers

UNION ALL

SELECT 'missing_product' as error_type, product_id as missing_key
FROM missing_products

UNION ALL

SELECT 'missing_datetime' as error_type, datetime_id as missing_key
FROM missing_datetimes