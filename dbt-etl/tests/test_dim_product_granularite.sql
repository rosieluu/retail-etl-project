-- Test de granularité pour dim_product
-- Vérifie qu'il n'y a pas de doublons sur product_id
SELECT 
    product_id,
    COUNT(*) as nb_occurrences
FROM {{ ref('dim_product') }}
GROUP BY product_id
HAVING COUNT(*) > 1


-- Test pour snap_dim_product  
SELECT 
    product_id as customer_id,
    COUNT(*) as nb_current_records
FROM {{ ref('snap_dim_product') }}
WHERE dbt_valid_to IS NULL
GROUP BY product_id
HAVING COUNT(*) > 1