# Guide des Snapshots dbt - Retail ETL Project

## Vue d'ensemble

Les snapshots dbt permettent de capturer l'évolution historique des données en implémentant une logique SCD Type 2 (Slowly Changing Dimensions de type 2).

## Snapshots disponibles

### 1. `snap_dim_customer`
- **Table source** : `dim_customer`
- **Stratégie** : `timestamp` 
- **Clé unique** : `customer_id`
- **Colonne de tracking** : `updated_at`

### 2. `snap_dim_product`
- **Table source** : `dim_product`
- **Stratégie** : `check`
- **Clé unique** : `product_id`
- **Colonnes surveillées** : `stock_code`, `description`, `price`

### 3. `snap_raw_invoice`
- **Table source** : `raw_invoice`
- **Stratégie** : `timestamp`
- **Clé unique** : `InvoiceNo + StockCode`
- **Colonne de tracking** : `snapshot_timestamp`

## Stratégies de détection des changements

### Strategy: `timestamp`
- Utilise une colonne timestamp pour détecter les changements
- Plus efficace pour les grandes tables
- Nécessite une colonne `updated_at` fiable

### Strategy: `check`
- Compare les valeurs de colonnes spécifiques
- Plus précis mais plus coûteux en calcul
- Idéal quand pas de colonne timestamp disponible

## Commandes principales

### Exécuter tous les snapshots
```bash
dbt snapshot
```

### Exécuter un snapshot spécifique
```bash
dbt snapshot --models snap_dim_customer
dbt snapshot --models snap_dim_product
dbt snapshot --models snap_raw_invoice
```

### Exécuter avec sélection
```bash
# Tous les snapshots qui commencent par "snap_dim"
dbt snapshot --models snap_dim*

# Snapshots d'un tag spécifique
dbt snapshot --models tag:daily
```

## Structure des tables snapshot

Chaque table snapshot contient les colonnes originales plus :

- `dbt_scd_id` : Identifiant unique du snapshot
- `dbt_updated_at` : Timestamp de la dernière mise à jour
- `dbt_valid_from` : Date de début de validité
- `dbt_valid_to` : Date de fin de validité (NULL = actuel)

## Exemple d'usage

### Interroger l'état actuel
```sql
SELECT *
FROM {{ ref('snap_dim_customer') }}
WHERE dbt_valid_to IS NULL
```

### Voir l'historique d'un client
```sql
SELECT 
    customer_id,
    country,
    dbt_valid_from,
    dbt_valid_to
FROM {{ ref('snap_dim_customer') }}
WHERE customer_id = 'specific_customer_id'
ORDER BY dbt_valid_from
```

### Voir les changements sur une période
```sql
SELECT *
FROM {{ ref('snap_dim_product') }}
WHERE dbt_valid_from >= '2024-01-01'
  AND dbt_valid_from < '2024-02-01'
```

## Bonnes pratiques

### 1. Fréquence d'exécution
- **Quotidienne** : Pour la plupart des dimensions
- **Horaire** : Pour les données critiques à haute fréquence
- **Hebdomadaire** : Pour les données de référence stables

### 2. Gestion de l'espace
```sql
-- Archiver les anciens snapshots (> 2 ans)
DELETE FROM snapshots.snap_dim_customer
WHERE dbt_valid_to < DATE_SUB(CURRENT_DATE(), INTERVAL 2 YEAR)
```

### 3. Monitoring
- Surveiller la taille des tables snapshots
- Alerter en cas d'absence de nouveaux snapshots
- Vérifier la cohérence des `dbt_valid_from/to`

## Tests recommandés

### Test d'unicité sur l'état actuel
```sql
-- tests/test_snapshot_current_uniqueness.sql
SELECT 
    customer_id,
    COUNT(*) as nb_records
FROM {{ ref('snap_dim_customer') }}
WHERE dbt_valid_to IS NULL
GROUP BY customer_id
HAVING COUNT(*) > 1
```

### Test de continuité temporelle
```sql
-- tests/test_snapshot_temporal_continuity.sql
WITH gaps AS (
    SELECT 
        customer_id,
        dbt_valid_to,
        LEAD(dbt_valid_from) OVER (PARTITION BY customer_id ORDER BY dbt_valid_from) as next_valid_from
    FROM {{ ref('snap_dim_customer') }}
    WHERE dbt_valid_to IS NOT NULL
)
SELECT *
FROM gaps
WHERE dbt_valid_to != next_valid_from
```

## Intégration CI/CD

### Dans workflow.yaml
```yaml
- name: Run snapshots
  run: dbt snapshot
  
- name: Test snapshots
  run: dbt test --models snapshots
```

### Scheduling optimal
- **Snapshots** : Après `dbt run` mais avant `dbt test`
- **Ordre** : `run` → `snapshot` → `test`