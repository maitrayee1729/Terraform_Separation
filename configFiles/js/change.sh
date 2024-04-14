tenant=$1
tenant_name_lower=`echo ${tenant}|tr '[:upper:]' '[:lower:]'`

sed "s/TENANT_LOWER/${tenant_name_lower}/g; s/TENANT/${tenant}/g" tenantprofile.js > modified_tenantprofile.js


