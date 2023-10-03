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

resource "google_apikeys_key" "places_api_key" {
  name         = "trapa-places-api-key"
  display_name = "Trapa API Places Service API Key"

  restrictions {
    api_targets {
      service = "places-backend.googleapis.com"
    }
  }
}