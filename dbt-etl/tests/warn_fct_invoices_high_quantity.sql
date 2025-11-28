-- Test : Vérifier les quantités anormalement élevées (> 1000)
-- Severity : WARN - Possible erreur de saisie

SELECT
    invoice_id,
    product_id,
    quantity,
    total,
    'Quantité suspecte : > 1000' as quality_issue
FROM {{ ref('fct_invoices') }}
WHERE quantity > 1000
