# Retail ETL Project - dbt Documentation

## 📊 Vue d'ensemble du projet

Ce projet dbt transforme les données brutes de vente retail en modèle dimensionnel optimisé pour l'analyse et le reporting. L'architecture suit les bonnes pratiques de modélisation en étoile avec séparation staging/transform.

## 🏗️ Architecture des données

```
Sources (BigQuery)
    ↓
[Staging Layer] (Views)
    ↓
[Transform Layer] (Tables)
    ├── dim_customer (Dimension clients)
    ├── dim_product (Dimension produits)
    ├── dim_datetime (Dimension temporelle)
    └── fct_invoices (Faits de vente)
    ↓
[Snapshots] (Historique SCD Type 2)
    ├── snap_dim_customer
    ├── snap_dim_product
    └── snap_raw_invoice
```

## 📋 Modèles disponibles

### 🎯 Tables de faits
- **`fct_invoices`** : Transactions de vente avec métriques calculées

### 📐 Tables de dimensions
- **`dim_customer`** : Clients uniques par pays avec codes ISO
- **`dim_product`** : Produits avec gestion des variations de prix
- **`dim_datetime`** : Dimension temporelle avec composants date/heure

### 📸 Snapshots (SCD Type 2)
- **`snap_dim_customer`** : Historique des changements clients
- **`snap_dim_product`** : Historique des changements produits
- **`snap_raw_invoice`** : Historique des données sources

## 🚀 API FastAPI - Endpoints disponibles

| Endpoint | Description | Commande équivalente |
|----------|-------------|---------------------|
| `GET /run` | Exécuter les modèles | `dbt run` |
| `GET /test` | Lancer les tests | `dbt test` |
| `GET /snapshot` | Capturer les snapshots | `dbt snapshot` |
| `GET /full-pipeline` | Pipeline complet | `dbt run && dbt snapshot && dbt test` |
| `GET /docs/generate` | Générer documentation | `dbt docs generate` |
| `GET /docs/serve` | Servir documentation | `dbt docs serve` |

### Démarrage de l'API
```bash
cd dbt-etl
python main.py
# API disponible sur http://localhost:8000
```

---

# Tests de Granularité DBT

## Vue d'ensemble

Ce projet contient des tests pour vérifier la granularité et l'intégrité des tables de dimension et de fait.

## Types de tests implémentés

### 1. Tests de schéma (schema.yml)
- **Unicité** : Vérifie que les clés primaires sont uniques
- **Non-null** : Vérifie que les colonnes critiques ne sont pas nulles
- **Valeurs acceptées** : Vérifie que les valeurs sont dans des plages valides
- **Intégrité référentielle** : Vérifie que les clés étrangères existent dans les tables de référence

### 2. Tests personnalisés (dossier tests/)
- **test_dim_customer_granularite.sql** : Vérifie l'unicité par pays
- **test_dim_datetime_granularite.sql** : Vérifie l'unicité par datetime_id
- **test_dim_product_granularite.sql** : Vérifie l'unicité par combinaison stock_code + description + price
- **test_referential_integrity.sql** : Vérifie l'intégrité des clés étrangères

## Comment exécuter les tests

### Tous les tests
```bash
dbt test
```

### Tests d'un modèle spécifique
```bash
dbt test --models dim_customer
dbt test --models dim_datetime
dbt test --models dim_product
dbt test --models fct_invoices
```

### Tests personnalisés uniquement
```bash
dbt test --models test_type:generic
```

### Tests de schéma uniquement
```bash
dbt test --models test_type:schema
```

### Exécuter avec mode verbose pour plus de détails
```bash
dbt test --verbose
```

## Granularité attendue

### dim_customer
- **Clé primaire** : `customer_id` (surrogate key de CustomerID + Country)
- **Granularité** : Un enregistrement par combinaison unique de client et pays

### dim_datetime
- **Clé primaire** : `datetime_id` (datetime original)
- **Granularité** : Un enregistrement par datetime unique

### dim_product
- **Clé primaire** : `product_id` (surrogate key de StockCode + Description + UnitPrice)
- **Granularité** : Un enregistrement par combinaison unique de produit et prix

### fct_invoices
- **Clé primaire** : `invoice_id`
- **Granularité** : Un enregistrement par ligne de facture

## Résolution des échecs de tests

Si un test échoue :

1. **Unicité** : Vérifiez s'il y a des doublons dans vos données sources
2. **Non-null** : Vérifiez s'il y a des valeurs manquantes
3. **Intégrité référentielle** : Vérifiez si toutes les clés étrangères ont des correspondances

### Déboguer un test spécifique
```bash
# Compile le test sans l'exécuter pour voir la requête SQL
dbt compile --models test_dim_customer_granularite

# Exécuter le test en mode debug
dbt test --models test_dim_customer_granularite --verbose
```


# Guide des Snapshots dbt - Retail ETL Project

## Vue d'ensemble

### Les snapshots dbt permettent de capturer l'évolution historique des données en implémentant une logique SCD Type 2 (Slowly Changing Dimensions de type 2).

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