# Trapa Infrastructure
Deploys the cloud infrastructure required to host the Trapa app. 

Firebase CLI is used to manage the manually created Firebase projects. 

Terraform is used to deploy Google Cloud Resources to Google Cloud Platform projects backing the corresponding Firebase projects. 

## Environment Setup
1. Create a project through Firebase console for the environment
2. Create a storage bucket through Google Cloud console: https://console.cloud.google.com/storage/browser
    - This bucket is used for storing the terraform state file
    - Bucket name convention: `terraform.<project>.<organisation-domain>`.
    - When a public domain name is used in the bucket name like this, then only the verified owner of the domain name is allowed to create the bucket. This means the account needs to be manually by a user created rather than created through a service account. 
    - Enable object versioning on the bucket as recommended by Terraform documentation: https://developer.hashicorp.com/terraform/language/settings/backends/gcs
3. Set bucket name and project name in `terraform/environments/<ENV>/main.tf` 
