
terraform {
  required_version = ">= 0.16.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.52.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

provider "openstack" {
  user_name   = "cyyoon@cafe24corp.com"
  tenant_name = "project-cyyoon@cafe24corp.com"
  token       = var.token
  auth_url    = "https://dev-kolla.cafe24cloud.kr:36081"
  region      = "RegionOne"
}

