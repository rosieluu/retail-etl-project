#!/bin/bash

# Script to upload data to Google Cloud Storage
PROJECT_ID="ext3rncrm"
BUCKET_NAME="retail-raw-data-ext3rncrm"

#activate config gcloud
gcloud config set project $PROJECT_ID

# Upload data files to GCS bucket
gsutil cp ./data/*.csv gs://$BUCKET_NAME/
echo "Data files uploaded to gs://$BUCKET_NAME/"
echo "Upload complete."
echo "Check the GCS bucket to verify the uploaded files and then Cloud workflow execution."
