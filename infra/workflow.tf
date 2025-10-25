# Service Account pour le workflow
resource "google_service_account" "workflow_sa" {
  account_id   = "workflow-sa"
  display_name = "Workflow Service Account"
}

# Permissions pour le workflow
resource "google_project_iam_member" "workflow_invoker" {
  project = var.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.workflow_sa.email}"
}

resource "google_project_iam_member" "workflow_bigquery_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_service_account.workflow_sa.email}"
}

resource "google_project_iam_member" "workflow_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.workflow_sa.email}"
}

resource "google_project_iam_member" "workflow_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.workflow_sa.email}"
}

# Création du workflow
resource "google_workflows_workflow" "data_ingestion_workflow" {
  name            = "data-ingestion-workflow"
  region          = var.region
  description     = "Workflow to ingest data from GCS to BigQuery and trigger dbt"
  service_account = google_service_account.workflow_sa.email

  source_contents = templatefile("${path.module}/workflow.yaml", {
    project_id    = var.project_id
    dataset_id    = var.dataset_id
    bucket_name   = var.bucket_name
    cloud_run_url = google_cloud_run_service.dbt_service.status[0].url
  })

  depends_on = [
    google_cloud_run_service.dbt_service
  ]
}

# Trigger Pub/Sub pour le workflow
resource "google_eventarc_trigger" "gcs_trigger" {
  name     = "gcs-trigger-workflow"
  location = var.region

  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }

  destination {
    workflow = google_workflows_workflow.data_ingestion_workflow.id
  }

  transport {
    pubsub {
      topic = google_pubsub_topic.gcs_topic.id
    }
  }

  service_account = google_service_account.workflow_sa.email
}