-- Test : Détecter les descriptions de produits manquantes
-- Severity : WARN - Qualité des données

SELECT
    product_id,
    stock_code,
    description,
    price,
    'Description manquante ou vide' as quality_issue
FROM {{ ref('dim_product') }}
WHERE description IS NULL 
   OR TRIM(description) = ''
