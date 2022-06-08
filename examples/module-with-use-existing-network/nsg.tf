## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_network_security_group" "my_lb_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "my_lb_nsg"
}

resource "oci_core_network_security_group_security_rule" "my_lb_nsg_egress_rule1" {
  network_security_group_id = oci_core_network_security_group.my_lb_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# LBSecurityGroup Rules - INGRESS

resource "oci_core_network_security_group_security_rule" "my_lb_nsg_ingres_rule1" {
  network_security_group_id = oci_core_network_security_group.my_lb_nsg.id
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

resource "oci_core_network_security_group_security_rule" "my_lb_nsg_ingres_rule2" {
  network_security_group_id = oci_core_network_security_group.my_lb_nsg.id
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

resource "oci_core_network_security_group" "my_webapp_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "my_webapp_nsg"
}

# EGRESS Rules - APPSecurityGroup 
resource "oci_core_network_security_group_security_rule" "my_webapp_nsg_egress_rule1" {
  network_security_group_id = oci_core_network_security_group.my_webapp_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# INGRESS Rules - APPSecurityGroup 

resource "oci_core_network_security_group_security_rule" "my_webapp_nsg_ingress_rule1" {
  network_security_group_id = oci_core_network_security_group.my_webapp_nsg.id
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

resource "oci_core_network_security_group" "my_ssh_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "my_ssh_nsg"
}

# EGRESS Rules - APPSecurityGroup 
resource "oci_core_network_security_group_security_rule" "my_ssh_nsg_egress_rule1" {
  network_security_group_id = oci_core_network_security_group.my_ssh_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# INGRESS Rules - APPSecurityGroup 

resource "oci_core_network_security_group_security_rule" "my_ssh_nsg_ingress_rule1" {
  network_security_group_id = oci_core_network_security_group.my_ssh_nsg.id
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
