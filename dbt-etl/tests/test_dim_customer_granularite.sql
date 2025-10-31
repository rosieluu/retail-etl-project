-- Test de granularité pour dim_customer
-- Vérifie qu'il n'y a pas de doublons sur customer_id
SELECT 
    customer_id,
    COUNT(*) as nb_occurrences
FROM {{ ref('dim_customer') }}
GROUP BY customer_id
HAVING COUNT(*) > 1