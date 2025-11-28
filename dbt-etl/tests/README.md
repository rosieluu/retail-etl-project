# Tests de Qualité des Données (Data Quality)

Ce dossier contient des tests de qualité configurés en mode **WARNING** (severity: warn).

## 🎯 Principe

Les tests ici **alertent** sans **bloquer** le build :
- ✅ Le pipeline continue même si des anomalies sont détectées
- ⚠️  Les warnings sont visibles dans les logs pour investigation
- 📊 Permet de monitorer la qualité sans casser la production

## 📋 Tests disponibles

| Test | Cible | Condition | Impact |
|------|-------|-----------|--------|
| `warn_dim_product_low_price` | dim_product | Prix < 0.10 | Pricing suspect |
| `warn_dim_product_missing_description` | dim_product | Description vide | Données incomplètes |
| `warn_dim_customer_missing_iso` | dim_customer | Code ISO null | Référentiel incomplet |
| `warn_dim_datetime_future_dates` | dim_datetime | Date > aujourd'hui | Erreur de saisie |
| `warn_fct_invoices_high_quantity` | fct_invoices | Quantité > 1000 | Volume anormal |
| `warn_fct_invoices_high_total` | fct_invoices | Total > 10000 | Transaction suspecte |

## 🚀 Exécution

```bash
# Exécuter tous les tests (warnings + erreurs)
dbt test

# Exécuter uniquement les tests de qualité (warnings)
dbt test --select tag:data_quality

# Exécuter uniquement les tests de pricing
dbt test --select tag:pricing

# Voir les warnings sans bloquer
dbt test --warn-error=False
```

## 📊 Interprétation des résultats

```bash
# Résultat normal avec warnings
WARN  test warn_dim_product_low_price .................... [WARN 5]
PASS  test dim_customer_customer_id_unique .............. [PASS]
```

- `[WARN X]` = X lignes détectées, mais build continue
- `[FAIL X]` = X lignes détectées, build échoue (tests normaux)
- `[PASS]` = Aucune anomalie détectée

## 🔧 Configuration

La sévérité est définie dans `tests/schema.yml` :

```yaml
tests:
  - name: warn_dim_product_low_price
    config:
      severity: warn  # ← Mode alerte
      tags: ['data_quality', 'pricing']
```

## 📈 Bonnes pratiques

1. **Monitorer régulièrement** les warnings
2. **Investiguer** les anomalies récurrentes
3. **Ajuster les seuils** selon le contexte métier
4. **Ajouter des tests** pour de nouvelles règles métier

## 🎨 Tags disponibles

- `data_quality` : Tous les tests de qualité
- `pricing` : Tests liés aux prix
- `volume` : Tests de volumétrie
- `revenue` : Tests de revenus
- `reference_data` : Tests de données de référence
- `completeness` : Tests d'exhaustivité
- `temporal` : Tests temporels

## 📝 Ajouter un nouveau test

1. Créer un fichier `warn_*.sql` dans `tests/`
2. Écrire une requête qui retourne les lignes problématiques
3. Ajouter la configuration dans `tests/schema.yml`

```sql
-- tests/warn_mon_test.sql
SELECT
    column_id,
    'Description du problème' as quality_issue
FROM {{ ref('ma_table') }}
WHERE condition_anormale
```

```yaml
# tests/schema.yml
tests:
  - name: warn_mon_test
    description: "Description du test"
    config:
      severity: warn
      tags: ['data_quality', 'mon_tag']
```
