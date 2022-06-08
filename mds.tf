## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  tomcat_mds_subnet_db = !var.use_existing_vcn ? oci_core_subnet.tomcat_mds_vcn_subnet_db[0].id : var.mysql_db_system_subnet_id
}

module "mds-instance" {
    providers                                       = { oci = oci.targetregion }
    source                                          = "github.com/oracle-devrel/terraform-oci-cloudbricks-mysql-database?ref=v1.0.4.1"
    tenancy_ocid                                    = var.tenancy_ocid
    region                                          = var.region
    mysql_instance_compartment_ocid                 = var.compartment_ocid
    mysql_network_compartment_ocid                  = var.compartment_ocid
    subnet_id                                       = local.tomcat_mds_subnet_db
    mysql_db_system_admin_username                  = var.mysql_db_system_admin_username
    mysql_db_system_admin_password                  = var.mysql_db_system_admin_password
    mysql_db_system_availability_domain             = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
    mysql_shape_name                                = var.mysql_db_system_shape
    mysql_db_system_display_name                    = var.mysql_db_system_db_name
    mysql_db_system_data_storage_size_in_gb         = var.mysql_db_system_data_storage_size_in_gb
    mysql_db_system_description                     = var.mysql_db_system_description  
    mysql_db_system_hostname_label                  = var.mysql_db_system_hostname_label
    mysql_db_system_fault_domain                    = var.mysql_db_system_fault_domain
    mysql_db_system_maintenance_window_start_time   = var.mysql_db_system_maintenance_window_start_time
    mysql_db_system_defined_tags                    = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
