-- Test de granularité pour dim_datetime
-- Vérifie qu'il n'y a pas de doublons sur datetime_id
SELECT 
    datetime_id,
    COUNT(*) as nb_occurrences
FROM {{ ref('dim_datetime') }}
GROUP BY datetime_id
HAVING COUNT(*) > 1