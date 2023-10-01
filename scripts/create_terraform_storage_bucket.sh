#!/bin/bash

if [ -z "$PROJECT_ID" ] || [ -z "$BUCKET_NAME" ]; then
    echo "Please set the PROJECT_ID and BUCKET_NAME environment variables."
    exit 1
fi

if gsutil ls -p "$PROJECT_ID" | grep -q "gs://$BUCKET_NAME/"; then
    echo "Bucket gs://$BUCKET_NAME already exists."
else
    echo "Creating bucket gs://$BUCKET_NAME in project $PROJECT_ID..."
    gcloud storage buckets create "gs://$BUCKET_NAME" --project "$PROJECT_ID"
    if [ $? -eq 0 ]; then
        echo "Bucket gs://$BUCKET_NAME created successfully."
    else
        echo "Error creating bucket gs://$BUCKET_NAME."
        exit 1
    fi
    echo "Enabling object versioning on bucket gs://$BUCKET_NAME..."
    gcloud storage buckets update "gs://$BUCKET_NAME" --versioning
    if [ $? -eq 0 ]; then
        echo "Object versioning successfully enabled on bucket gs://$BUCKET_NAME"
    else
        echo "Error enabling object versioning on bucket gs://$BUCKET_NAME."
        exit 1
    fi
fi