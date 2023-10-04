data "google_project" "project" {
}

resource "google_project_service" "places_service" {
  project = var.projectName
  service = "places-backend.googleapis.com"
}

resource "google_project_service" "secrets_service" {
  project = var.projectName
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "apikeys_service" {
  project = var.projectName
  service = "apikeys.googleapis.com"
}

resource "google_project_service" "registry_service" {
  project = var.projectName
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "iam_service" {
  project = var.projectName
  service = "iam.googleapis.com"
}

resource "google_project_service" "cloud_run_service" {
  project = var.projectName
  service = "run.googleapis.com"
}


resource "google_apikeys_key" "places_api_key" {
  name         = "trapa-places-api-key"
  display_name = "Trapa API Places Service API Key"

  restrictions {
    api_targets {
      service = "places-backend.googleapis.com"
    }
  }

  depends_on = [
    google_project_service.places_service,
    google_project_service.apikeys_service,
  ]
}

resource "google_secret_manager_secret" "places_api_key_secret" {
  secret_id = "places-api-key"


  replication {
    auto {}
  }

  depends_on = [
    google_project_service.secrets_service
  ]
}

resource "google_secret_manager_secret_version" "places_api_key_secret_version" {
  secret = google_secret_manager_secret.places_api_key_secret.id

  secret_data = google_apikeys_key.places_api_key.key_string
}

resource "google_service_account" "trapa_api_service_account" {
  account_id   = "trapa-api-service-account"
  display_name = "Trapa API Service Account"

  # Creation of service accounts is eventually consistent:
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "google_secret_manager_secret_iam_member" "trapa_api_places_secret_access" {
  secret_id  = google_secret_manager_secret.places_api_key_secret.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.trapa_api_service_account.email}"
  depends_on = [google_project_service.iam_service]
}

resource "google_cloud_run_v2_service" "trapa_api" {
  name     = "trapa-api"
  location = var.location
  ingress  = "INGRESS_TRAFFIC_ALL"
  template {
    service_account = google_service_account.trapa_api_service_account.email
    containers {
      # Deploy a placeholder image to ensure the service is created
      image = "us-docker.pkg.dev/cloudrun/container/placeholder"

      env {
        name  = "GOOGLE_CLOUD_PROJECT_NAME"
        value = var.projectName
      }
      env {
        name  = "GOOGLE_CLOUD_PROJECT_ID"
        value = data.google_project.project.number
      }
    }
  }

  depends_on = [google_project_service.cloud_run_service]

  # Ignore changes to the image so that we can update the service as part
  # of the API build and deploy pipeline
  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
    ]
  }
}

# Make the Trapa API service publicly accessible. Authentication will be handled
# within the API itself rather than through the Cloud Run environment.
data "google_iam_policy" "trapa_api_noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "trapi_api_noauth" {
  location    = google_cloud_run_v2_service.trapa_api.location
  project     = google_cloud_run_v2_service.trapa_api.project
  name        = google_cloud_run_v2_service.trapa_api.name
  policy_data = data.google_iam_policy.trapa_api_noauth.policy_data
}
