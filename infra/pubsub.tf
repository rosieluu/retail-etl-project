# Création du topic Pub/Sub
resource "google_pubsub_topic" "gcs_topic" {
  name = "gcs-events-topic"
}

# Permission pour GCS de publier sur le topic
resource "google_pubsub_topic_iam_member" "storage_publisher" {
  topic  = google_pubsub_topic.gcs_topic.id
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

# Récupérer le numéro du projet
data "google_project" "project" {
  project_id = var.project_id
}