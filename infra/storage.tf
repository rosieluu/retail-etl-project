# Création du bucket GCS
resource "google_storage_bucket" "raw_data_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# Notification Pub/Sub pour le bucket
resource "google_storage_notification" "bucket_notification" {
  bucket         = google_storage_bucket.raw_data_bucket.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.gcs_topic.id
  event_types    = ["OBJECT_FINALIZE"]

  depends_on = [google_pubsub_topic_iam_member.storage_publisher]
}