{% snapshot snap_dim_product %}

{{
    config(
      target_database='your_project_id',
      target_schema='snapshots',
      unique_key='product_id',
      strategy='check',
      check_cols=['stock_code', 'description', 'price'],
    )
}}

-- Snapshot des produits avec détection des changements sur colonnes spécifiques
SELECT 
    *,
    CURRENT_TIMESTAMP() as updated_at
FROM {{ ref('dim_product') }}

{% endsnapshot %}