## Copyright (c) 2021 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "mysql_db_system_admin_password" {}
variable "numberOfNodes" {}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

module "oci-arch-tomcat-mds" {
  source                         = "github.com/oracle-devrel/terraform-oci-arch-tomcat-mds"
  tenancy_ocid                   = var.tenancy_ocid
  user_ocid                      = var.user_ocid
  fingerprint                    = var.fingerprint
  region                         = var.region
  private_key_path               = var.private_key_path
  compartment_ocid               = var.compartment_ocid
  numberOfNodes                  = var.numberOfNodes
  mysql_db_system_admin_password = var.mysql_db_system_admin_password
}

output "todoapp_url" {
  value = module.oci-arch-tomcat-mds.todoapp_url
}

output "generated_ssh_private_key" {
  value     = module.oci-arch-tomcat-mds.generated_ssh_private_key
  sensitive = true
}
