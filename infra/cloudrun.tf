# Service Account pour Cloud Run
resource "google_service_account" "cloudrun_sa" {
  account_id   = "cloudrun-dbt-sa"
  display_name = "Cloud Run dbt Service Account"
}

# Permissions BigQuery pour Cloud Run
resource "google_project_iam_member" "cloudrun_bigquery_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

# Permissions Secret Manager pour Cloud Run
resource "google_project_iam_member" "cloudrun_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

# Création du service Cloud Run (placeholder, sera déployé par Cloud Build)
resource "google_cloud_run_service" "dbt_service" {
  name     = "dbt-service"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.cloudrun_sa.email

      containers {
        image = "gcr.io/cloudrun/hello"  # Image placeholder

        resources {
          limits = {
            memory = "512Mi"
            cpu    = "1"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].metadata
    ]
  }
}

# Permettre l'accès non authentifié (à ajuster selon vos besoins de sécurité)
resource "google_cloud_run_service_iam_member" "noauth" {
  service  = google_cloud_run_service.dbt_service.name
  location = google_cloud_run_service.dbt_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}