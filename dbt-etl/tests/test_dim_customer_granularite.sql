-- Test de granularité pour dim_customer
-- Vérifie qu'il n'y a pas de doublons sur customer_id
SELECT 
    customer_id,
    COUNT(*) as nb_occurrences
FROM {{ ref('dim_customer') }}
GROUP BY customer_id
HAVING COUNT(*) > 1


-- Test d'unicité pour l'état actuel des snapshots
-- Vérifie qu'il n'y a qu'un seul enregistrement "current" par clé

-- Test pour snap_dim_customer
SELECT 
    customer_id,
    COUNT(*) as nb_current_records
FROM {{ ref('snap_dim_customer') }}
WHERE dbt_valid_to IS NULL
GROUP BY customer_id
HAVING COUNT(*) > 1

UNION ALL
