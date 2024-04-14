#!/bin/bash


value=$1
workspace=$2
#scp -r -i /var/lib/jenkins/.ssh/Build.pem $workspace/configFiles/pinpoint-agent-2.5.2 build@"$value":/tmp/
#ssh -i /var/lib/jenkins/.ssh/Build.pem build@"$value" "sudo mv /tmp/pinpoint-agent-2.5.2 /usr/local/apache-tomcat/conf/uniwareConfig"
ssh -i /var/lib/jenkins/.ssh/Build.pem build@"$value" "sudo chown -R uniware:uniware /usr/local/apache-tomcat/conf/uniwareConfig/pinpoint-agent-2.5.2"
