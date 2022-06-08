## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "my_vcn" {
  cidr_block     = "192.168.0.0/16"
  dns_label      = "myvcn"
  compartment_id = var.compartment_ocid
  display_name   = "my_vcn"
}

resource "oci_core_internet_gateway" "my_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vcn.id
  enabled        = "true"
  display_name   = "my_igw"
}

resource "oci_core_nat_gateway" "my_natgw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "my_natgw"
}

resource "oci_core_default_route_table" "my_public_rt" {
  manage_default_resource_id = oci_core_vcn.my_vcn.default_route_table_id
  display_name               = "my_public_rt"
  route_rules {
    network_entity_id = oci_core_internet_gateway.my_igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_default_security_list" "my_default_sec_list" {
  manage_default_resource_id = oci_core_vcn.my_vcn.default_security_list_id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
}

resource "oci_core_security_list" "my_mds_sec_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "my_mds_sec_list"
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
}

resource "oci_core_security_list" "my_http80_sec_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "my_http80_sec_list"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    protocol = 6
    source   = "0.0.0.0/0"

    source_type = "CIDR_BLOCK"
    tcp_options {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_security_list" "my_http8080_sec_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "my_http8080_sec_list"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    protocol = 6
    source   = "0.0.0.0/0"

    source_type = "CIDR_BLOCK"
    tcp_options {
      max = 8080
      min = 8080
    }
  }
}

resource "oci_core_security_list" "my_ssh_sec_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "my_ssh_sec_list"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    protocol = 6
    source   = "0.0.0.0/0"

    source_type = "CIDR_BLOCK"
    tcp_options {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_route_table" "my_private_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vcn.id
  display_name   = "my_private_rt"
  route_rules {
    network_entity_id = oci_core_nat_gateway.my_natgw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "my_lb_subnet" {
  cidr_block        = "192.168.1.0/24"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.my_vcn.id
  dns_label         = "lbsub"
  security_list_ids = [oci_core_security_list.my_http80_sec_list.id]
  display_name      = "my_lb_subnet1"
}

resource "oci_core_subnet" "my_bastion_subnet" {
  cidr_block        = "192.168.2.0/24"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.my_vcn.id
  dns_label         = "bassub"
  security_list_ids = [oci_core_security_list.my_ssh_sec_list.id]
  display_name      = "my_bastion_subnet"
}

resource "oci_core_subnet" "my_compute_subnet" {
  cidr_block                 = "192.168.3.0/24"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.my_vcn.id
  display_name               = "my_compute_subnet"
  dns_label                  = "vmsub"
  security_list_ids          = [oci_core_security_list.my_ssh_sec_list.id, oci_core_security_list.my_http8080_sec_list.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_route_table_attachment" "my_compute_private_rt_attachment" {
  subnet_id      = oci_core_subnet.my_compute_subnet.id
  route_table_id = oci_core_route_table.my_private_rt.id
}

resource "oci_core_subnet" "my_mds_subnet" {
  cidr_block                 = "192.168.4.0/24"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.my_vcn.id
  display_name               = "my_mds_subnet"
  dns_label                  = "mdssub"
  security_list_ids          = [oci_core_security_list.my_mds_sec_list.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_route_table_attachment" "my_mds_private_rt_attachment" {
  subnet_id      = oci_core_subnet.my_mds_subnet.id
  route_table_id = oci_core_route_table.my_private_rt.id
}

resource "oci_core_subnet" "my_fss_subnet" {
  cidr_block                 = "192.168.5.0/24"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.my_vcn.id
  display_name               = "my_fss_subnet"
  dns_label                  = "fsssub"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_route_table_attachment" "my_fss_private_rt_attachment" {
  subnet_id      = oci_core_subnet.my_fss_subnet.id
  route_table_id = oci_core_route_table.my_private_rt.id
}
