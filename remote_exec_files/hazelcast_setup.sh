#!/bin/bash +x

host=$1
ServerName=$2

export IFS=","
members=(`grep -o '\-DhazelcastMembers=[^ ]*' /usr/local/apache-tomcat/bin/catalina.sh | sed "s|-DhazelcastMembers=||1"`)

for member_name in ${members[@]};
do
    echo "          - $member_name" >>  /usr/local/apache-tomcat/bin/hazelcast.yml
done
