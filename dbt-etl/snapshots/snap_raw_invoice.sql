{% snapshot snap_raw_invoice %}

{{
    config(
      target_database='your_project_id',
      target_schema='snapshots',
      unique_key=['InvoiceNo', 'StockCode'],
      strategy='timestamp',
      updated_at='snapshot_timestamp',
    )
}}

-- Snapshot des données brutes de factures
SELECT 
    *,
    CURRENT_TIMESTAMP() as snapshot_timestamp
FROM {{ source('retail_dsy', 'raw_invoice') }}

{% endsnapshot %}