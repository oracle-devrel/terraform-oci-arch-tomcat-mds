## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# SSHSecurityGroup

resource "oci_core_network_security_group" "SSHSecurityGroup" {
  provider       = oci.targetregion
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name   = "Bastion_NSG"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# SSHSecurityGroup Rules - EGRESS

resource "oci_core_network_security_group_security_rule" "SSHSecurityEgressGroupRule" {
  provider                  = oci.targetregion
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.SSHSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# SSHSecurityGroup Rules - INGRES

resource "oci_core_network_security_group_security_rule" "SSHSecurityIngressGroupRules" {
  provider                  = oci.targetregion
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.SSHSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

# LBSecurityGroup

resource "oci_core_network_security_group" "LBSecurityGroup" {
  provider       = oci.targetregion
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name   = "LB_NSG"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


# LBSecurityGroup Rules - EGRESS

resource "oci_core_network_security_group_security_rule" "LBSecurityEgressInternetGroupRule" {
  provider                  = oci.targetregion
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# LBSecurityGroup Rules - INGRESS

resource "oci_core_network_security_group_security_rule" "LBSecurityIngressGroupRules_TCP80" {
  provider                  = oci.targetregion
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "LBSecurityIngressGroupRules_TCP443" {
  provider                  = oci.targetregion
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.LBSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

# APPSecurityGroup

resource "oci_core_network_security_group" "APPSecurityGroup" {
  provider       = oci.targetregion
  count          = !var.use_existing_nsg ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.tomcat_mds_vcn[0].id
  display_name   = "APP_NSG"
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

# EGRESS Rules - APPSecurityGroup 
resource "oci_core_network_security_group_security_rule" "APPSecurityEgressGroupRules" {
  provider                  = oci.targetregion
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.APPSecurityGroup[0].id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# INGRESS Rules - APPSecurityGroup 

resource "oci_core_network_security_group_security_rule" "APPSecurityIngressGroupRules" {
  provider                  = oci.targetregion
  count                     = !var.use_existing_nsg ? 1 : 0
  network_security_group_id = oci_core_network_security_group.APPSecurityGroup[0].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 8080
      min = 8080
    }
  }
}


