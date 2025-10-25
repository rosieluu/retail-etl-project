# Création du dataset BigQuery
resource "google_bigquery_dataset" "retail_dataset" {
  dataset_id                 = var.dataset_id
  friendly_name              = "Retail Dataset"
  description                = "Dataset for retail ELT pipeline"
  location                   = var.region
  delete_contents_on_destroy = true
}

# Table pour les invoices brutes
resource "google_bigquery_table" "raw_invoice" {
  dataset_id          = google_bigquery_dataset.retail_dataset.dataset_id
  table_id            = "raw_invoice"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "InvoiceNo"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "StockCode"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "Description"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "Quantity"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "InvoiceDate"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "UnitPrice"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "CustomerID"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "Country"
      type = "STRING"
      mode = "NULLABLE"
    }
  ])
}

# Table pour les pays de référence
resource "google_bigquery_table" "raw_country" {
  dataset_id          = google_bigquery_dataset.retail_dataset.dataset_id
  table_id            = "raw_country"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "iso"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "name"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "nicename"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "iso3"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "numcode"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "phonecode"
      type = "STRING"
      mode = "NULLABLE"
    }
  ])
}