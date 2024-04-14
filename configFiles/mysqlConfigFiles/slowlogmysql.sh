#!/bin/bash

DATE=`date +'%Y%m%d'`
HOSTNAME=`hostname -f | awk -F "." '{print $2}'`

echo $HOSTNAME 
echo $DATE
sudo chmod 664 /var/lib/mysql/slow-slow.log-$DATE.gz
sudo chmod 644 /var/lib/mysql/mysql-slow.log
sudo mv /var/lib/mysql/slow-slow.log-$DATE.gz /var/lib/mysql/$HOSTNAME.slow-slow.log-$DATE.gz
sshpass -p "host@987" scp /var/lib/mysql/$HOSTNAME.slow-slow.log-$DATE.gz  hostmanager@uclog.unicommerce.infra:/applogs/replicalog/ 
