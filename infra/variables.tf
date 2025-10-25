variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "ext3rncrm"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west1"
}

variable "dataset_id" {
  description = "BigQuery Dataset ID"
  type        = string
  default     = "retail_dsy"
}

variable "bucket_name" {
  description = "GCS Bucket name for raw data"
  type        = string
  default     = "retail-raw-data-ext3rncrm"
}