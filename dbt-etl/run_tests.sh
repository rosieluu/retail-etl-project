#!/bin/bash

# Script pour exécuter les tests dbt avec différentes options

echo "=== Tests DBT - Retail ETL Project ==="
echo ""

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -a, --all           Exécuter tous les tests"
    echo "  -s, --schema        Exécuter uniquement les tests de schéma"
    echo "  -c, --custom        Exécuter uniquement les tests personnalisés"
    echo "  -m, --model MODEL   Exécuter les tests pour un modèle spécifique"
    echo "  -v, --verbose       Mode verbose"
    echo "  -h, --help          Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 -a              # Tous les tests"
    echo "  $0 -m dim_customer # Tests pour dim_customer seulement"
    echo "  $0 -s -v           # Tests de schéma en mode verbose"
}

# Variables par défaut
VERBOSE=""
MODEL=""
TEST_TYPE=""

# Parser les arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            TEST_TYPE="all"
            shift
            ;;
        -s|--schema)
            TEST_TYPE="schema"
            shift
            ;;
        -c|--custom)
            TEST_TYPE="custom"
            shift
            ;;
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="--verbose"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

# Construire la commande dbt test
DBT_CMD="dbt test"

if [[ -n "$MODEL" ]]; then
    DBT_CMD="$DBT_CMD --models $MODEL"
elif [[ "$TEST_TYPE" == "schema" ]]; then
    DBT_CMD="$DBT_CMD --models test_type:schema"
elif [[ "$TEST_TYPE" == "custom" ]]; then
    DBT_CMD="$DBT_CMD --models test_type:generic"
fi

if [[ -n "$VERBOSE" ]]; then
    DBT_CMD="$DBT_CMD $VERBOSE"
fi

# Afficher la commande qui va être exécutée
echo "Commande à exécuter: $DBT_CMD"
echo ""

# Exécuter la commande
eval $DBT_CMD

# Afficher le résultat
if [[ $? -eq 0 ]]; then
    echo ""
    echo "✅ Tous les tests ont réussi!"
else
    echo ""
    echo "❌ Certains tests ont échoué. Consultez les logs ci-dessus."
    echo ""
    echo "Pour déboguer un test spécifique:"
    echo "  dbt compile --models nom_du_test"
    echo "  dbt test --models nom_du_test --verbose"
fi