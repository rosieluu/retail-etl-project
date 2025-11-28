-- Test : Vérifier les clients sans code pays ISO
-- Severity : WARN - Données de référence manquantes

SELECT
    customer_id,
    country,
    iso,
    'Code ISO manquant' as quality_issue
FROM {{ ref('dim_customer') }}
WHERE iso IS NULL
