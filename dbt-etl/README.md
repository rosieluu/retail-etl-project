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