-- Test : Vérifier les prix anormalement bas (< 0.10)
-- Severity : WARN - Alerte mais ne bloque pas le build

SELECT
    product_id,
    stock_code,
    description,
    price,
    'Prix suspect : inférieur à 0.10' as quality_issue
FROM {{ ref('dim_product') }}
WHERE price < 0.10
