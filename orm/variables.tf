## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.7"
}

variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}
#variable "fingerprint" {}
#variable "user_ocid" {}
#variable "private_key_path" {}

variable "availability_domain_name" {
  default = ""
}

variable "availability_domain_number" {
  default = 0
}

variable "mysql_db_system_admin_password" {}

variable "mysql_db_system_password" {}

variable "use_existing_vcn" {
  default = false
}

variable "use_existing_nsg" {
  default = false
}

variable "vcn_id" {
  default = ""
}

variable "lb_subnet_id" {
  default = ""
}

variable "lb_nsg_ids" {
  default = []
}

variable "compute_subnet_id" {
  default = ""
}

variable "fss_subnet_id" {
  default = ""
}

variable "compute_nsg_ids" {
  default = []
}

variable "mysql_db_system_subnet_id" {
  default = ""
}

variable "bastion_subnet_id" {
  default = ""
}

variable "bastion_nsg_ids" {
  default = []
}

variable "use_bastion_service" {
  default = false
}

variable "ssh_public_key" {
  default = ""
}

variable "numberOfNodes" {
  default = 2
}

variable "tomcat_version" {
  default = "9.0.45"
}

variable "tomcat_mds_vcn_cidr_block" {
  default = "10.0.0.0/16"
}

variable "tomcat_mds_vcn_display_name" {
  default = "tomcat_mds_vcn"
}

variable "tomcat_mds_vcn_subnet_lb_cidr_block" {
  default = "10.0.1.0/24"
}

variable "tomcat_mds_vcn_subnet_lb_display_name" {
  default = "tomcat_mds_vcn_subnet_lb"
}

variable "tomcat_mds_vcn_subnet_bastion_cidr_block" {
  default = "10.0.2.0/24"
}

variable "tomcat_mds_vcn_subnet_bastion_display_name" {
  default = "tomcat_mds_vcn_subnet_bastion"
}

variable "tomcat_mds_vcn_subnet_app_cidr_block" {
  default = "10.0.10.0/24"
}

variable "tomcat_mds_vcn_subnet_app_display_name" {
  default = "tomcat_mds_vcn_subnet_app"
}

variable "tomcat_mds_vcn_subnet_db_cidr_block" {
  default = "10.0.20.0/24"
}

variable "tomcat_mds_vcn_subnet_db_display_name" {
  default = "tomcat_mds_vcn_subnet_db"
}

variable "tomcat_mds_vcn_subnet_fss_cidr_block" {
  default = "10.0.30.0/24"
}

variable "tomcat_mds_vcn_subnet_fss_display_name" {
  default = "tomcat_mds_vcn_subnet_fss"
}

variable "lb_shape" {
  default = "flexible"
}

variable "flex_lb_min_shape" {
  default = "10"
}

variable "flex_lb_max_shape" {
  default = "100"
}

variable "InstanceShape" {
  default = "VM.Standard.E3.Flex"
}

variable "InstanceFlexShapeOCPUS" {
  default = 1
}

variable "InstanceFlexShapeMemory" {
  default = 1
}

variable "BastionShape" {
  default = "VM.Standard.E3.Flex"
}

variable "BastionFlexShapeOCPUS" {
  default = 1
}

variable "BastionFlexShapeMemory" {
  default = 1
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "8"
}

variable "mysql_db_system_admin_username" {
  default = "admin"
}

variable "mysql_db_system_username" {
  default = "todoapp"
}

variable "mysql_db_system_db_name" {
  default = "TomcatMDS"
}

variable "mysql_db_system_shape" {
  default = "MySQL.VM.Standard.E3.1.8GB"
}

variable "mysql_db_system_is_highly_available" {
  default = false
}

variable "mysql_db_system_backup_policy_is_enabled" {
  default = true
}

variable "mysql_db_system_data_storage_size_in_gb" {
  default = 50
}

variable "mysql_db_system_description" {
  default = "MySQL DB System for TomcatMDS"
}

variable "mysql_db_system_display_name" {
  default = "TomcatMDS"
}

variable "mysql_db_system_fault_domain" {
  default = "FAULT-DOMAIN-1"
}                  

variable "mysql_db_system_hostname_label" {
  default = "TomcatMDS"
}
   
variable "mysql_db_system_maintenance_window_start_time" {
  default = "SUNDAY 14:30"
}



