-- Test : Vérifier les dates dans le futur
-- Severity : WARN - Erreur possible de saisie de date

SELECT
    datetime_id,
    datetime,
    year,
    month,
    day,
    'Date dans le futur' as quality_issue
FROM {{ ref('dim_datetime') }}
WHERE datetime > CURRENT_DATETIME()
