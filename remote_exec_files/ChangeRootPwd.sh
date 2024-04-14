#!/bin/bash +x

workspace="$1"
mysql_host="$2"
private_key="$3"

ROOT_USER="`grep 'ROOT_USER' ${workspace}/remote_exec_files/creds.txt | awk '{print $NF}'`"
ROOT_PWD="`grep 'ROOT_PWD' ${workspace}/remote_exec_files/creds.txt | awk '{print $NF}'`"
DEFAULT_PWD="`grep 'WORMHOLE_PWD' ${workspace}/remote_exec_files/creds.txt | awk '{print $NF}'`"

ssh -i ${private_key} -t -t -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no build@${mysql_host} "mysqladmin --user=${ROOT_USER} --password=${DEFAULT_PWD} password \"${ROOT_PWD}\""

ssh -i ${private_key} -t -t -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no build@${mysql_host} "mysql -u${ROOT_USER} -p${ROOT_PWD} -e \"flush privileges;\""

ssh -i ${private_key} -t -t -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no build@${mysql_host} "mysql -u${ROOT_USER} -p${ROOT_PWD} -e \"alter user 'root'@'%' identified by '${ROOT_PWD}'\"";
