## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  vcn_id                = !var.use_existing_vcn ? oci_core_vcn.tomcat_mds_vcn[0].id : var.vcn_id
  tomcat_mds_subnet_lb  = !var.use_existing_vcn ? oci_core_subnet.tomcat_mds_vcn_subnet_lb[0].id : var.lb_subnet_id
  tomcat_mds_subnet_app = !var.use_existing_vcn ? oci_core_subnet.tomcat_mds_vcn_subnet_app[0].id : var.compute_subnet_id
  tomcat_mds_subnet_fss = !var.use_existing_vcn ? oci_core_subnet.tomcat_mds_vcn_subnet_fss[0].id : var.fss_subnet_id
}

module "oci-arch-tomcat" {
  providers                           = { oci = oci.targetregion }
  source                              = "github.com/oracle-devrel/terraform-oci-arch-tomcat"
  tenancy_ocid                        = var.tenancy_ocid
  vcn_id                              = local.vcn_id
  numberOfNodes                       = var.numberOfNodes
  availability_domain_name            = var.availability_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availability_domain_name
  compartment_ocid                    = var.compartment_ocid
  tomcat_version                      = var.tomcat_version
  tomcat_http_port                    = "8080"
  image_id                            = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
  shape                               = var.InstanceShape
  flex_shape_ocpus                    = var.InstanceFlexShapeOCPUS
  flex_shape_memory                   = var.InstanceFlexShapeMemory
  label_prefix                        = ""
  ssh_authorized_keys                 = var.ssh_public_key
  tomcat_subnet_id                    = local.tomcat_mds_subnet_app
  lb_subnet_id                        = local.tomcat_mds_subnet_lb
  fss_subnet_id                       = local.tomcat_mds_subnet_fss
  display_name                        = "tomcatvm"
  lb_shape                            = var.lb_shape 
  flex_lb_min_shape                   = var.flex_lb_min_shape 
  flex_lb_max_shape                   = var.flex_lb_max_shape 
  oci_adb_setup                       = false
  oci_mds_setup                       = true
  oci_mds_db_name                     = var.mysql_db_system_db_name
  oci_mds_username                    = var.mysql_db_system_username
  oci_mds_password                    = var.mysql_db_system_password
  oci_mds_ip_address                  = module.mds-instance.mysql_db_system.ip_address
  use_bastion_service                 = local.use_bastion_service ? true : false
  inject_bastion_service_id           = local.use_bastion_service ? true : false
  bastion_service_id                  = local.use_bastion_service ? oci_bastion_bastion.bastion_service[0].id : ""
  bastion_service_region              = local.use_bastion_service ? var.region : ""
  inject_bastion_server_public_ip     = local.use_bastion_host ? true : false
  bastion_server_public_ip            = local.use_bastion_host ? oci_core_instance.bastion_instance[0].public_ip : ""
  bastion_server_private_key          = local.use_bastion_host ? tls_private_key.public_private_key_pair.private_key_pem : ""  
  defined_tags                        = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
