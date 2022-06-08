## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "mysql_db_system_admin_password" {}
variable "mysql_db_system_password" {}
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
  mysql_db_system_password       = var.mysql_db_system_password
  use_existing_vcn               = true
  use_existing_nsg               = true
  use_bastion_service            = false
  vcn_id                         = oci_core_vcn.my_vcn.id
  lb_subnet_id                   = oci_core_subnet.my_lb_subnet.id
  lb_nsg_ids                     = [oci_core_network_security_group.my_lb_nsg.id]
  compute_subnet_id              = oci_core_subnet.my_compute_subnet.id
  fss_subnet_id                  = oci_core_subnet.my_fss_subnet.id
  compute_nsg_ids                = [oci_core_network_security_group.my_webapp_nsg.id, oci_core_network_security_group.my_ssh_nsg.id]
  mysql_db_system_subnet_id      = oci_core_subnet.my_mds_subnet.id
  bastion_subnet_id              = oci_core_subnet.my_bastion_subnet.id
  bastion_nsg_ids                = [oci_core_network_security_group.my_ssh_nsg.id]
}

output "tomcat_demo_app_URL" {
  value = module.oci-arch-tomcat-mds.tomcat_demo_app_URL
}

output "generated_ssh_private_key_for_tomcat_servers" {
  value     = module.oci-arch-tomcat-mds.generated_ssh_private_key_for_tomcat_servers
  sensitive = true
}
