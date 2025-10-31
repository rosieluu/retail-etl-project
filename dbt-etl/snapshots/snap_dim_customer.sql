{% snapshot snap_dim_customer %}

{{
    config(
      target_database='your_project_id',
      target_schema='snapshots',
      unique_key='customer_id',
      strategy='timestamp',
      updated_at='updated_at',
    )
}}

-- Ajout d'une colonne updated_at pour le tracking
SELECT 
    *,
    CURRENT_TIMESTAMP() as updated_at
FROM {{ ref('dim_customer') }}

{% endsnapshot %}