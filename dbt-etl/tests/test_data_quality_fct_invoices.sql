-- Test de cohérence des données dans fct_invoices
-- Vérifie que les calculs et les valeurs sont logiques

SELECT *
FROM (
    -- Test 1: Vérifier que quantity et total sont cohérents
    SELECT 
        invoice_id,
        'quantity_total_mismatch' as error_type,
        'Quantity or total should be positive' as error_description
    FROM {{ ref('fct_invoices') }}
    WHERE quantity <= 0 OR total <= 0

    UNION ALL

    -- Test 2: Vérifier qu'il n'y a pas de valeurs aberrantes dans les montants
    SELECT 
        invoice_id,
        'extreme_values' as error_type,
        'Total amount seems unrealistic (>10000 or <0.01)' as error_description
    FROM {{ ref('fct_invoices') }}
    WHERE total > 10000 OR total < 0.01

    UNION ALL

    -- Test 3: Vérifier qu'il n'y a pas de quantités aberrantes
    SELECT 
        invoice_id,
        'extreme_quantity' as error_type,
        'Quantity seems unrealistic (>1000)' as error_description
    FROM {{ ref('fct_invoices') }}
    WHERE quantity > 1000
) errors
WHERE errors.invoice_id IS NOT NULL