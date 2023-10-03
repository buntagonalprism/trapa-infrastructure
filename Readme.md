# Trapa Infrastructure
Deploys the cloud infrastructure required to host the Trapa app. 

Firebase CLI is used to manage the manually created Firebase projects. 

Terraform is used to deploy Google Cloud Resources to Google Cloud Platform projects backing the corresponding Firebase projects. 

## Setup for Each Environment
1. Create project
    1. Create a project through Firebase console for the environment
    2. Enable billing on the project
2. Configure Terraform backend using a Cloud Storage bucket 
    1. Create a storage bucket through Google Cloud console: https://console.cloud.google.com/storage/browser
        - This bucket is used for storing the terraform state file
        - Bucket name convention: `terraform.<project>.<organisation-domain>`.
        - When a public domain name is used in the bucket name like this, then only the verified owner of the domain name is allowed to create the bucket. This means the account needs to be manually by a user created rather than created through a service account. 
        - Enable object versioning on the bucket as recommended by Terraform documentation: https://developer.hashicorp.com/terraform/language/settings/backends/gcs
    2. Set bucket name and project name in `terraform/environments/<ENV>/main.tf` 
3. Configure service account for github actions to authenticate to Google Cloud Platform
    1. Create a service account for the with "owner" permissions so that terraform can perform all management actions https://console.cloud.google.com/iam-admin/serviceaccounts
    2. Create a "JSON" key type for the service account by selecting the "Manage Keys" under the actions of the new service account
    3. Remove all newlines from the secret JSON file - see here for reason https://github.com/google-github-actions/auth/blob/main/docs/TROUBLESHOOTING.md#aggressive-replacement
    4. Create a Github actions secret `<ENV>_GOOGLE_SERVICE_ACCOUNT_KEY`

## To Do
- Migrate to Workflow Identity Federation for authenticating Github Actions instead of using a service account key
