#!/bin/bash

####  Run if user hits control-c
control_c () {
  echo  -e '\n' "\n\033[5;31m   O Hoo!!" '\n'; tput sgr0
  exit $?
}

##### Script variables #####
hostname=`hostname`
display_name="$hostname"
key="/opt/.ssh.pem"
pki_dir="/var/lib/icinga2/certs"
icinga2_master="icinga2.unicommerce.infra"
icinga2_master_port=5665
plugins_path=/usr/lib64/nagios/plugins
notification=${1:-icingaadmins}
instance_id=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
ticket=`curl -k -s -u root:805d1384ff2675a9 -H 'Accept: application/json' -X POST 'https://'$icinga2_master':5665/v1/actions/generate-ticket' -d '{ "cn": "'$hostname'" }' | grep -Eo "\"ticket\":\"(.+?)\"" | cut -d: -f2 | cut -d\" -f2`

####### Proxy Set ########
export https_proxy=http://$icinga2_master:3128
export http_proxy=http://$icinga2_master:3128

###### Client Installation #######
sudo yum clean all
rm -rf /var/cache/yum
yum -y install icinga2 nagios-plugins-all vim-icinga2 sysstat perl-ExtUtils-MakeMaker  perl-Test-Simple perl-Sys-Statistics-Linux

####### Enable/Disable feature ########

icinga2 feature enable command  api
icinga2 feature disable checker

####### Enable at Startup ########
systemctl enable icinga2

unset https_proxy
unset http_proxy

#### SSL Configuration ######
rm -rf $pki_dir/*
mkdir $pki_dir
chown icinga:icinga $pki_dir; chmod 0700 $pki_dir;

icinga2 pki new-cert --cn $hostname --key $pki_dir/$hostname.key --cert $pki_dir/$hostname.crt
icinga2 pki save-cert --key $pki_dir/$hostname.key --cert $pki_dir/$hostname.crt --trustedcert $pki_dir/trusted-master.crt --host $icinga2_master
icinga2 pki request --host $icinga2_master --port $icinga2_master_port --ticket $ticket --key $pki_dir/$hostname.key --cert $pki_dir/$hostname.crt --trustedcert $pki_dir/trusted-master.crt --ca $pki_dir/ca.key
icinga2 node setup --ticket $ticket --endpoint $icinga2_master,$icinga2_master,$icinga2_master_port --zone $hostname --master_host $icinga2_master --trustedcert $pki_dir/trusted-master.crt --accept-commands --accept-config

####### SSH Key ##########
cat > $key << EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAqZyzW72c8NgfkubOkOQrs0a+YGx6E9bFshvkBO40NfmukaD6
fWwO8X3fQg4NtICDLSjSD2IBKFKU1I1Gk+22WHa1CKe7hW3sGqakwdUwfmDnCEHH
hMekpWr0aIzDBFV0Um6WkCQsocrmvJkHbUxjvXkI9gk1a2Gy+cHw4b+4yXIwb37q
LmrzuEvP0AP7VybbbVAP+FM3s9LQVGSU0t/8TJ62NDvGnAqe8IOxz6qNsrH4IVPz
CkL2tQ/0mRZWiyQuQlhcuv5wsttsU3HZvP1y+oQBiAerKU1vN32/MzQbzm6V2ekN
0+wnKFjLm0ZkExNQK8+GHt+IIYHaO427/iuToQIDAQABAoIBAHT8AbFa/K4ZQt29
l+fTmFiUiKZU63ZXgg+wsPq9mQFJbyA+mcZ8C2qA2MXkj4tZwCAbsZaukAHRw5k+
v9kz8breVUrc9be380sGeUi/1Cy2hWLqi8SHNoZpWJ3ryG5qyko4wFw2txn4qmCW
Y8r9DyYWHxoji9a+kgU1wQDTjY5StoXZyDAzq1NOPnhos7UmxF0jABQfZn6MGQjT
fzsz8i+VS+2S58CT4Gag+Qtc2AFn2E0Oq25PKvFELWol/dvI2YyYi0cMLR7FH6wt
S5/IpQqUh7ETixfSi4Mrc5oMXPdHKEbqkZYq2F+FW/UyMMPhk5TrPtRIfOmJmtfW
7Wlq+GkCgYEA1sPz0dSf+w/bePbI7uITUn9NVfLfFxNRWzUA87p9cYSJ1qkDeDW0
1yGFFu5bB0GFG9RUcjC2rzUPZZn96E2zjgSb8X1nLhlS1uZR0UxQb91vQFBQUV4q
Q2BYcFi1QLVuvt8KkpKr88aqXYry4ZSGGrYRrD+n2AdpelSaDhCrrzMCgYEAyi1k
wNPgFl/TBVBICjzy3ANpK/90C29AuflLL3iIV/LvKys4L3rrEF20xD6CYBZyhdk4
UQK3zTZE0ngaut4y90Tk5AiG+37HJrK5QOYW25B4kO7jbEKPLWTRSrMIXtIRxdeG
NTR4uBMS78+GJC+W8ROQ/3IwN3hPSRH5DXfsgdsCgYEAumtXHgFZaL1H/cUBf1Hg
AdEcmQl7mnUbPndQvz9Wmg249Aq7R0IfGkovU0tM2oyF9TUmpAQi3wzIs6Gqo1Wn
ERRxJHp88KfsnztHM8zxWVi1s/bC8Q4y008zFTn7AxM58RZ7/+Suu6jrwszUrPiW
O2NlDcYndD5i0VvUaXcQ/78CgYEAsunw22OkTqiGCZG97rF5CZJLJBBwFR5i3TDr
hBraLVpipIUet4XDNzx1l6Tpoza6KhDMcYRCO2vnA4odvXidCY0CMXoKWc0bV/eZ
UQFNAQicaUW+JDPSmI07WSuOILst1zKfJb5Fhj/65hVz09n5bWWvTx8x5CSnpTYu
e+jAdzkCgYEAugoGMTjJTbfdv0DN96jrSTe4pmwnIq0f7RSBsmkhmNkIuHNiVoyB
GVcO3/wjxJ34eJ/FmQWtOKV1i8ZpRkLLSjDQpVuB7a+/8mSRIz0Re/AaDjy/cD70
PrLyvJUy+Yo+REmKdkcrHI9uYccz2kDCp1p5ApQIUP1oVilBHtv92bc=
-----END RSA PRIVATE KEY-----
EOF

chmod 600 $key

####### Pluggin copy from Icinga master servers #########
scp -i $key -o StrictHostKeyChecking=no  root@$icinga2_master:/var/www/html/plugins/* $plugins_path

####### Restart Icinga Client #######

/bin/systemctl restart icinga2.service

yum -y install perl-DBI perl-DBD-MySQL

###### Generate host object to Icinga master servers #########

ssh -i $key -o StrictHostKeyChecking=no root@$icinga2_master ''$plugins_path'/host_add '$hostname' '$notification' && exit'

if [ $? -ne 0 ]; then

echo "Host exists"
###### Delete SSH Key/Script ########
/bin/rm -f  $key ./icingacl_centos7

exit 1
fi
####### Reload Icinga master servers ######

ssh -i $key -o StrictHostKeyChecking=no root@$icinga2_master '/bin/systemctl reload icinga2.service && exit'

###### Delete SSH Key/Script ########
/bin/rm -f  $key ./icingacl_centos7

exit 0
