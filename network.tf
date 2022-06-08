## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "tomcat_mds_vcn" {
  provider       = oci.targetregion
  count          = !var.use_existing_vcn ? 1 : 0
  cidr_block     = var.tomcat_mds_vcn_cidr_block
  dns_label      = "tomvcn"
  compartment_id = var.compartment_ocid
  display_name   = var.tomcat_mds_vcn_display_name
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#IGW
resource "oci_core_internet_gateway" "tomcat_mds_internet_gateway" {
  provider       = oci.targetregion
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name   = "tomcat_mds_internet_gateway"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_nat_gateway" "tomcat_mds_nat_gateway" {
  provider       = oci.targetregion
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name   = "tomcat_mds_nat_gateway"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "tomcat_mds_igw_route_table" {
  provider       = oci.targetregion
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name   = "tomcat_mds_igw_route_table"
  route_rules {
    network_entity_id = oci_core_internet_gateway.tomcat_mds_internet_gateway[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_route_table" "tomcat_mds_nat_route_table" {
  provider       = oci.targetregion
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name   = "tomcat_mds_nat_route_table"
  route_rules {
    network_entity_id = oci_core_nat_gateway.tomcat_mds_nat_gateway[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_core_security_list" "tomcat_mds_ssh_security_list" {
  provider       = oci.targetregion
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "tomcat_mds_ssh_security_list"
  vcn_id         = oci_core_vcn.tomcat_mds_vcn[0].id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "tomcat_mds_lb_http_security_list" {
  provider       = oci.targetregion
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "tomcat_mds_lb_http_security_list"
  vcn_id         = oci_core_vcn.tomcat_mds_vcn[0].id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 80
      min = 80
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "tomcat_mds_http_security_list" {
  provider       = oci.targetregion
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "tomcat_mds_http_security_list"
  vcn_id         = oci_core_vcn.tomcat_mds_vcn[0].id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 8080
      min = 8080
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "tomcat_mds_db_security_list" {
  provider       = oci.targetregion
  count          = !var.use_existing_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name   = "tomcat_mds_db_security_list"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    protocol = 6
    source   = "0.0.0.0/0"

    source_type = "CIDR_BLOCK"
    tcp_options {
      max = 3306
      min = 3306
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = "0.0.0.0/0"

    source_type = "CIDR_BLOCK"
    tcp_options {
      max = 33060
      min = 33060
    }
  }
  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#tomcat_mds loadbalancer subnet
resource "oci_core_subnet" "tomcat_mds_vcn_subnet_lb" {
  provider       = oci.targetregion
  count          = !var.use_existing_vcn ? 1 : 0
  cidr_block     = var.tomcat_mds_vcn_subnet_lb_cidr_block
  compartment_id = var.compartment_ocid
  dns_label      = "lbsub"
  vcn_id         = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name   = var.tomcat_mds_vcn_subnet_lb_display_name
  security_list_ids = [oci_core_security_list.tomcat_mds_lb_http_security_list[0].id]
  route_table_id = oci_core_route_table.tomcat_mds_igw_route_table[0].id 
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#tomcat_mds bastion subnet
resource "oci_core_subnet" "tomcat_mds_vcn_subnet_bastion" {
  provider          = oci.targetregion
  count             = !var.use_existing_vcn ? 1 : 0
  cidr_block        = var.tomcat_mds_vcn_subnet_bastion_cidr_block
  compartment_id    = var.compartment_ocid
  dns_label         = "bassub"
  vcn_id            = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name      = var.tomcat_mds_vcn_subnet_bastion_display_name
  security_list_ids = [oci_core_security_list.tomcat_mds_ssh_security_list[0].id]
  route_table_id    = oci_core_route_table.tomcat_mds_igw_route_table[0].id 
  defined_tags      = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#tomcat_mds app subnet
resource "oci_core_subnet" "tomcat_mds_vcn_subnet_app" {
  provider                   = oci.targetregion
  count                      = !var.use_existing_vcn ? 1 : 0
  cidr_block                 = var.tomcat_mds_vcn_subnet_app_cidr_block
  compartment_id             = var.compartment_ocid
  dns_label                  = "tomsub"
  vcn_id                     = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name               = var.tomcat_mds_vcn_subnet_app_display_name
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_security_list.tomcat_mds_http_security_list[0].id, oci_core_security_list.tomcat_mds_ssh_security_list[0].id]
  route_table_id             = oci_core_route_table.tomcat_mds_nat_route_table[0].id 
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#tomcat_mds fss subnet
resource "oci_core_subnet" "tomcat_mds_vcn_subnet_fss" {
  provider                   = oci.targetregion
  count                      = !var.use_existing_vcn ? 1 : 0
  cidr_block                 = var.tomcat_mds_vcn_subnet_fss_cidr_block
  compartment_id             = var.compartment_ocid
  dns_label                  = "fsssub"
  vcn_id                     = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name               = var.tomcat_mds_vcn_subnet_fss_display_name
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.tomcat_mds_nat_route_table[0].id 
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

#tomcat_mds db subnet
resource "oci_core_subnet" "tomcat_mds_vcn_subnet_db" {
  provider                   = oci.targetregion
  count                      = !var.use_existing_vcn ? 1 : 0
  cidr_block                 = var.tomcat_mds_vcn_subnet_db_cidr_block
  compartment_id             = var.compartment_ocid
  dns_label                  = "mdssub"
  vcn_id                     = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name               = var.tomcat_mds_vcn_subnet_db_display_name
  security_list_ids          = [oci_core_security_list.tomcat_mds_db_security_list[0].id]
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.tomcat_mds_nat_route_table[0].id 
  defined_tags               = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


