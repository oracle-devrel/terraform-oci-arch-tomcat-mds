## Copyright (c) 2021 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  use_bastion_service = var.use_bastion_service ? true : false 
  use_bastion_host = !var.use_bastion_service ? true : false 
}

resource "oci_bastion_bastion" "bastion_service" {
  provider                     = oci.targetregion
  count                        = var.use_bastion_service ? 1 : 0
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_ocid
  target_subnet_id             = !var.use_existing_vcn ? oci_core_subnet.tomcat_mds_vcn_subnet_app[0].id : var.compute_subnet_id
  client_cidr_block_allow_list = ["0.0.0.0/0"]
  defined_tags                 = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
  name                         = "BastionService${random_id.tag.hex}"
  max_session_ttl_in_seconds   = 10800
}

data "template_file" "key_script" {
  template = file("${path.module}/scripts/sshkey.tpl")
  vars = {
    ssh_public_key = tls_private_key.public_private_key_pair.public_key_openssh
  }
}

data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.key_script.rendered
  }
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.InstanceShape)
}

resource "oci_core_instance" "bastion_instance" {
  provider            = oci.targetregion
  count               = local.use_bastion_host ? 1 : 0
  availability_domain = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "BastionVM"
  shape               = var.BastionShape

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.BastionFlexShapeMemory
      ocpus         = var.BastionFlexShapeOCPUS
    }
  }

  create_vnic_details {
    subnet_id        = !var.use_existing_vcn ? oci_core_subnet.tomcat_mds_vcn_subnet_bastion[0].id : var.bastion_subnet_id
    display_name     = "bastionvm"
    assign_public_ip = true
    nsg_ids          = !var.use_existing_nsg ? [oci_core_network_security_group.SSHSecurityGroup[0].id] : var.bastion_nsg_ids
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.InstanceImageOCID.images[0].id
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }

  defined_tags = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}


