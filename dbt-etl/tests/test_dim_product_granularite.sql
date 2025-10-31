-- Test de granularité pour dim_product
-- Vérifie qu'il n'y a pas de doublons sur product_id
SELECT 
    product_id,
    COUNT(*) as nb_occurrences
FROM {{ ref('dim_product') }}
GROUP BY product_id
HAVING COUNT(*) > 1