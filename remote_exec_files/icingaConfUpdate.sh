#!/bin/bash +x

set -eo pipefail

###################################################################### VARIABLES #######################################################################

tenant="$1"
server_hostname="$2"
setup_type="$3"
replica_hostname="$4"
private_key="$5"
region="$6"
tenant_name_lower=`echo ${tenant}|tr '[:upper:]' '[:lower:]'`

########################################################################################################################################################

################################################################# ICINGA CONFIG UPDATE #############################################################
if [ "${region}" == "Mumbai" ]; then
    icinga_var= "icinga2-in.unicommerce.infra"
else
	icinga_var= "icinga2.unicommerce.infra"
fi


if [ "$setup_type" == "Standalone" ]; then
	#Add host vars to icinga conf
	ssh -i /var/lib/jenkins/.ssh/id_rsa centos@${icinga_var} "sudo sed -i '17ivars.tenant = \"${tenant_name_lower}\" \n  vars.server = \"Mysql\" \n  vars.ucenv = \"Standalone\" \n  vars.group_name = \"app1\" \n  vars.mysql = \"master\" \n  vars.app1 = \"true\"' /etc/icinga2/zones.d/master/app1.${tenant_name_lower}.unicommerce.infra.conf"
	ssh -i /var/lib/jenkins/.ssh/id_rsa centos@${icinga_var} "sudo sed -i '22ivars.mysql_channel[\"${tenant}\"] = { \n  channel = \"${tenant}\"  \n  hostname = \"${replica_hostname}\"} \n ' /etc/icinga2/zones.d/master/${replica_hostname}.conf "
else
	
	server_id=`echo ${server_hostname} | grep -o 'app[^.]*' | grep -o '[0-9]*'` || true
	if [ "${server_id}" == "" ]; then
		#Updating tags for db server
		if [ "$setup_type" == "Distributed_Setup" ]; then
			ssh -i /var/lib/jenkins/.ssh/id_rsa  centos@${icinga_var} "sudo sed -i '17ivars.server = \"Mysql\" \n  vars.ucenv = \"Seller-cloud\" \n  vars.mysql = \"master\"' /etc/icinga2/zones.d/master/${server_hostname}.conf"
		else 
			ssh -i /var/lib/jenkins/.ssh/id_rsa  centos@${icinga_var} "sudo sed -i '17ivars.server = \"Mysql\" \n  vars.ucenv = \"Standalone\" \n  vars.mysql = \"master\"' /etc/icinga2/zones.d/master/${server_hostname}.conf"
		fi
		ssh -i /var/lib/jenkins/.ssh/id_rsa centos@${icinga_var} "sudo sed -i '22ivars.mysql_channel[\"${tenant}\"] = { \n  channel = \"${tenant}\"  \n  hostname = \"${replica_hostname}\"} \n ' /etc/icinga2/zones.d/master/${replica_hostname}.conf "
	else
		#Initialise app3 servers with app1 icinga group and var
		if [ "${server_id}" -eq 2 ]; then
			icinga_group_name=2
			icinga_var_id=2
		
		fi
		
#Updating tags for app servers
		if [ "${region}" == "Singapore" ]; then
			ssh -i /var/lib/jenkins/.ssh/id_rsa centos@${icinga_var} "sudo sed -i '17ivars.tenant = \"${tenant_name_lower}\" \n  vars.group_name = \"app${icinga_group_name}\"  \n vars.app${icinga_var_id} = \"true\"' /etc/icinga2/zones.d/master/app${server_id}.${tenant_name_lower}.unicommerce.infra.conf"
		else
			ssh -i /var/lib/jenkins/.ssh/id_rsa centos@${icinga_var} "sudo sed -i '17ivars.tenant = \"${tenant_name_lower}\" \n  vars.group_name = \"app${icinga_group_name}\"  \n vars.app${icinga_var_id} = \"true\"' /etc/icinga2/zones.d/master/app${server_id}.${tenant_name_lower}-in.unicommerce.infra.conf"
		fi
	
	fi
	
fi

#Restart icinga service
ssh -i ${private_key} -t -t -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no build@${icinga_var} "sudo service icinga2 reload"

########################################################################################################################################################
