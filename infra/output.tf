output "bucket_name" {
  value       = google_storage_bucket.raw_data_bucket.name
  description = "Name of the GCS bucket"
}

output "dataset_id" {
  value       = google_bigquery_dataset.retail_dataset.dataset_id
  description = "BigQuery dataset ID"
}

output "cloud_run_url" {
  value       = google_cloud_run_service.dbt_service.status[0].url
  description = "Cloud Run service URL"
}

output "workflow_name" {
  value       = google_workflows_workflow.data_ingestion_workflow.name
  description = "Workflow name"
}

output "cloudrun_service_account_email" {
  value       = google_service_account.cloudrun_sa.email
  description = "Cloud Run Service Account email"
}