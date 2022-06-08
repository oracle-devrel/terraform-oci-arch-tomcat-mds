## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "tomcat_home_URL" {
  value = "http://${module.oci-arch-tomcat.public_ip[0]}/"
}

output "tomcat_demo_app_URL" {
  value = "http://${module.oci-arch-tomcat.public_ip[0]}/todoapp/list"
}

output "tomcat_private_ips" {
   value = module.oci-arch-tomcat.tomcat_nodes_private_ips
}

output "bastion_session_ids" {
   value = module.oci-arch-tomcat.bastion_session_ids
}

output "bastion_session_ssh_metadata" {
  value = module.oci-arch-tomcat.bastion_session_ssh_metadata
}

output "bastion_server_public_ip" {
  value = var.use_bastion_service ? "" : oci_core_instance.bastion_instance[0].public_ip 
}

output "generated_ssh_public_key_for_bastion_server" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

output "generated_ssh_private_key_for_tomcat_servers" {
  value     = module.oci-arch-tomcat.generated_ssh_private_key
  sensitive = true
}

output "generated_ssh_public_key_for_tomcat_servers" {
  value     = module.oci-arch-tomcat.generated_ssh_public_key
  sensitive = true
}

