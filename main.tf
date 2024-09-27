# Declare the required providers and their version constraints for this Terraform configuration
terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = ">=1.0.7"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.2.1"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">=2.3.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=4.0.4"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.94.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.58.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.3.0"
    }
  }
}

# Declare the provider for the AWS resource to be managed by Terraform
provider "aws" {
  region = "eu-west-2"
}

# Declare the provider for the HashiCorp Boundary resource to be managed by Terraform
provider "boundary" {
  # Use variables to provide values for the provider configuration
  addr                            = var.boundary_addr
  password_auth_method_login_name = var.password_auth_method_login_name
  password_auth_method_password   = var.password_auth_method_password
}

provider "hcp" {
  project_id = "5d8c9b59-f4d8-46d4-ba5c-f16b45e36dc6"
}

provider "vault" {
  address = hcp_vault_cluster.pki_vault.vault_public_endpoint_url
  token   = hcp_vault_cluster_admin_token.root_token.token
}
