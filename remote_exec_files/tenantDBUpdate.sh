#!/bin/bash +x

set -eo pipefail

###################################################################### VARIABLES #######################################################################

tenant="$1"
email_id="$2"
tenant_mongo_list="$3"
setup_type="$4"
replica_hostname="$5"
zookeeper_hostname="$6"
tenant_code="$7"
workspace="$8"
private_key="$9"


Tenant=${tenant}
tenant_name_lower=`echo ${tenant}|tr '[:upper:]' '[:lower:]'`
app1_hostname="app1.${tenant_name_lower}.unicommerce.infra"
app2_hostname="app2.${tenant_name_lower}.unicommerce.infra"
app3_hostname="app3.${tenant_name_lower}.unicommerce.infra"
db_hostname="db.${tenant_name_lower}.unicommerce.infra"
uniauth_db="db.uniauth.unicommerce.infra"

## Making directory on jenkins server for build
sudo mkdir /var/lib/jenkins/workspace/UniwareReleases/logs/${tenant}
sudo chown -R jenkins:jenkins /var/lib/jenkins/workspace/UniwareReleases/logs/${tenant}


########################################################################################################################################################

################################################################## MONGO CONFIG UPDATE #################################################################

#Create config as per setup_type
  sudo touch ${workspace}/${Tenant}/commonmongo.js
  echo -e "uniware db\n" > ${workspace}/${Tenant}/commonmongo.js
  
  sudo sed -e "s/TENANT_LOWER/${tenant_name_lower}/g" -e "s/TENANT/${Tenant}/g" ${workspace}/configFiles/js/tenantprofile.js >> ${workspace}/${Tenant}/commonmongo.js
  
  echo -e "uniwareConfig db\n" >> ${workspace}/${Tenant}/commonmongo.js
  sudo sed -e "s/NEW_SERVER_NAME/${tenant}/g" -e "s/SERVER_APP_VAR/${app1_hostname}/g" -e "s/SERVER_DB_VAR/${db_hostname}/g" -e "s/REPLICA_NAME/${replica_hostname}/g" -e "s/TENANT_MONGO_1/${TENANT_MONGO_1}/g" -e "s/TENANT_MONGO_2/${TENANT_MONGO_2}/g" -e "s/ZOOKEEPER_HOSTNAME/${zookeeper_hostname}/g" -e "s/^M//g" ${workspace}/configFiles/js/ServerUpdateMongo.js >> ${workspace}/${Tenant}/commonmongo.js
  
  echo -e "\n" >> ${workspace}/${Tenant}/commonmongo.js
  if [ "${setup_type}" == "Dedicated_Setup_Task" ]; then
  sudo sed -e "s/NEW_SERVER_NAME/${tenant}_2/g" -e "s/SERVER_APP_VAR/${app2_hostname}/g" -e "s/SERVER_DB_VAR/${db_hostname}/g" -e "s/REPLICA_NAME/${replica_hostname}/g" -e "s/TENANT_MONGO_1/${TENANT_MONGO_1}/g" -e "s/TENANT_MONGO_2/${TENANT_MONGO_2}/g" -e "s/ZOOKEEPER_HOSTNAME/${zookeeper_hostname}/g" -e "s/^M//g" ${workspace}/configFiles/js/ServerUpdateMongo.js >> ${workspace}/${Tenant}/commonmongo.js
  fi
########################################################################################################################################################

################################################### USER-PROFILE MIGRATION & DATASOURCE CONFIGURATION ##################################################
echo -e "\n" >> ${workspace}/${Tenant}/commonmongo.js
sudo sed -e "s/SERVER_NAME/${tenant}/g" -e "s/DB_HOSTNAME/${db_hostname}/g" -e "s/UNIWARE_USER/${UNIWARE_USER}/g" -e "s/UNIWARE_PWD/${UNIWARE_PWD}/g" ${workspace}/configFiles/js/DatasourceMain.js >> ${workspace}/${Tenant}/commonmongo.js

echo -e "\n" >> ${workspace}/${Tenant}/commonmongo.js
sudo sed -e "s/SERVER_NAME/${tenant}/g" -e "s/REPLICA_HOSTNAME/${db_hostname}/g" -e "s/REPLICA_USER/${REPLICA_USER}/g" -e "s/REPLICA_PWD/${REPLICA_PWD}/g" ${workspace}/configFiles/js/DatasourceReplication.js >> ${workspace}/${Tenant}/commonmongo.js

echo -e "\n" >> ${workspace}/${Tenant}/commonmongo.js
sudo sed -e "s/SERVER_NAME/${tenant}/g" -e "s/DB_HOSTNAME/${db_hostname}/g" -e "s/UNIWARE_USER/${UNIWARE_USER}/g" -e "s/UNIWARE_PWD/${UNIWARE_PWD}/g" ${workspace}/configFiles/js/hikariDatasourceMain.js >> ${workspace}/${Tenant}/commonmongo.js

echo -e "\n" >> ${workspace}/${Tenant}/commonmongo.js
sudo sed -e "s/SERVER_NAME/${tenant}/g" -e "s/REPLICA_HOSTNAME/${db_hostname}/g" -e "s/REPLICA_USER/${REPLICA_USER}/g" -e "s/REPLICA_PWD/${REPLICA_PWD}/g" ${workspace}/configFiles/js/hikariDatasourceReplication.js >> ${workspace}/${Tenant}/commonmongo.js

########################################################################################################################################################
if [ "${setup_type}" == "Dedicated_Setup_Task" ]; then
    sed -e "s/TENANT_LOWER/${tenant_name_lower}/g; s/TENANT/${Tenant}/g" "${workspace}/configFiles/js/HAProxy2.txt" >> "${workspace}/${Tenant}/HAProxy2.txt"
else
    sed -e "s/TENANT_LOWER/${tenant_name_lower}/g; s/TENANT/${Tenant}/g" "${workspace}/configFiles/js/HAProxy1.txt" >> "${workspace}/${Tenant}/HAProxy1.txt"
fi

########################################################################################################################################################

cp ${workspace}/${Tenant}/HAProxy* /tmp/${Tenant}/HAProxy*
cp ${workspace}/${Tenant}/commonmongo.js /tmp/${Tenant}/commonmongo.js

