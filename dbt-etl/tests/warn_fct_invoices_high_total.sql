-- Test : Vérifier les montants totaux anormalement élevés (> 10000)
-- Severity : WARN - Transactions inhabituelles à vérifier

SELECT
    invoice_id,
    customer_id,
    product_id,
    quantity,
    total,
    'Montant suspect : > 10000' as quality_issue
FROM {{ ref('fct_invoices') }}
WHERE total > 10000
