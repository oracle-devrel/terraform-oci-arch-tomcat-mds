## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "create_app_mds_sh_template" {
  template = file("${path.module}/scripts/create_app_mds.sh")
  vars = {
    oci_mds_admin_username              = var.mysql_db_system_admin_username
    oci_mds_admin_password              = var.mysql_db_system_admin_password
    oci_mds_db_name                     = var.mysql_db_system_db_name
    oci_mds_ip_address                  = module.mds-instance.mysql_db_system.ip_address
  }
}

data "template_file" "create_app_mds_sql_template" {
  template = file("${path.module}/sqls/create_app_mds.sql")
  vars = {
    oci_mds_username                    = var.mysql_db_system_username
    oci_mds_password                    = var.mysql_db_system_password
    oci_mds_admin_username              = var.mysql_db_system_admin_username
    oci_mds_db_name                     = var.mysql_db_system_db_name
  }
}

resource "null_resource" "mds_sql_exec" {
  depends_on = [module.oci-arch-tomcat.oci-arch-tomcat, module.mds-instance.mysql_db_system]

  count = var.numberOfNodes

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = module.oci-arch-tomcat.tomcat_nodes_private_ips[0]
      private_key         = module.oci-arch-tomcat.generated_ssh_private_key
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip 
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? module.oci-arch-tomcat.bastion_session_ids[count.index] : "opc"
      bastion_private_key = var.use_bastion_service ? module.oci-arch-tomcat.generated_ssh_private_key : tls_private_key.public_private_key_pair.private_key_pem 
    }
    content     = data.template_file.create_app_mds_sh_template.rendered
    destination = "/home/opc/create_app_mds.sh"
  }

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = module.oci-arch-tomcat.tomcat_nodes_private_ips[0]
      private_key         = module.oci-arch-tomcat.generated_ssh_private_key
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip 
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? module.oci-arch-tomcat.bastion_session_ids[count.index] : "opc"
      bastion_private_key = var.use_bastion_service ? module.oci-arch-tomcat.generated_ssh_private_key : tls_private_key.public_private_key_pair.private_key_pem 
    }
    content     = data.template_file.create_app_mds_sql_template.rendered
    destination = "/home/opc/create_app_mds.sql"
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = module.oci-arch-tomcat.tomcat_nodes_private_ips[0]
      private_key         = module.oci-arch-tomcat.generated_ssh_private_key
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip 
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? module.oci-arch-tomcat.bastion_session_ids[count.index] : "opc"
      bastion_private_key = var.use_bastion_service ? module.oci-arch-tomcat.generated_ssh_private_key : tls_private_key.public_private_key_pair.private_key_pem 
    }
    inline = [
      "echo '--> Running create_app_mds.sh...'",
      "more /home/opc/create_app_mds.sh",
      "chmod +x /home/opc/create_app_mds.sh",
      "sudo /home/opc/create_app_mds.sh",
      "echo '-[100%]-> create_app_mds.sh finished.'",
    ]
  }

}

resource "null_resource" "app_deployment" {
  depends_on = [null_resource.mds_sql_exec]

  count = var.numberOfNodes

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = module.oci-arch-tomcat.tomcat_nodes_private_ips[count.index]
      private_key         = module.oci-arch-tomcat.generated_ssh_private_key
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = var.use_bastion_service ? "host.bastion.${var.region}.oci.oraclecloud.com" : oci_core_instance.bastion_instance[0].public_ip 
      bastion_port        = "22"
      bastion_user        = var.use_bastion_service ? module.oci-arch-tomcat.bastion_session_ids[count.index] : "opc"
      bastion_private_key = var.use_bastion_service ? module.oci-arch-tomcat.generated_ssh_private_key : tls_private_key.public_private_key_pair.private_key_pem    
    }
    inline = [
      "echo '--> Downloading todoapp.war ...'",
      "wget -O /home/opc/todoapp.war https://github.com/oracle-devrel/terraform-oci-arch-tomcat-mds/releases/latest/download/todoapp.war",
      "sudo chown opc:opc /home/opc/todoapp.war",
      "echo '-[100%]-> todoapp.war downloaded.'",
      "echo '--> Deploying todoapp.war ...'",      
      "sudo cp /home/opc/todoapp.war /u01/apache-tomcat-${var.tomcat_version}/webapps",
      "sudo chown tomcat:tomcat /u01/apache-tomcat-${var.tomcat_version}/webapps/todoapp.war",
      "sleep 30",
      "echo '-[100%]-> todoapp.war deployed.'"
    ]
  }

}

