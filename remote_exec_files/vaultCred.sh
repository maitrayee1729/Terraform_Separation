#!/bin/bash

data=$1
tenant=$2
lowercase_tenant="${tenant,,}"

for i in $(echo $data | sed "s/,/ /g")
do

filename="serverdetails.txt"
  command=$(getServerDetails "$i")
  echo "$command" > "$filename"
  file_path="./serverdetails.txt"
  value=$(grep "App Hostname" "$filename" | awk '{print $NF}')
  value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

ssh -t -t -i /var/lib/jenkins/.ssh/Build.pem build@"$value" " cat /usr/local/apache-tomcat/conf/uniwareConfig/vaultCredentials.yml | grep $lowercase_tenant > /tmp/output.txt"
scp -i /var/lib/jenkins/.ssh/Build.pem build@"$value":/tmp/output.txt /var/lib/jenkins/workspace/Terraform_seperation/configFiles/apache-tomcat/conf/uniwareConfig/vaultCredentials.yml

echo output.txt

done
