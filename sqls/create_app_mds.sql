create database ${oci_mds_db_name};
use ${oci_mds_db_name};
CREATE USER '${oci_mds_username}'@'%' IDENTIFIED BY '${oci_mds_password}';
GRANT ALL on ${oci_mds_db_name}.* TO ${oci_mds_username}@"%";
CREATE TABLE todos (id bigint(20) NOT NULL AUTO_INCREMENT, title varchar(255) DEFAULT NULL, description varchar(255) DEFAULT NULL, is_done bit(1) NOT NULL, PRIMARY KEY (id)) AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci; 


