#!/bin/bash  +x

set -eo pipefail

function docker_hard_reset() {
    sudo systemctl daemon-reload
    sudo systemctl stop docker.socket
    sudo systemctl stop docker.service
    sudo rm -rf /var/run/docker.sock
    sudo systemctl start docker.service
}

#Main
docker_version=$1
scm_hostname=$2
scm_user=$3
scm_pwd=$4

#Add repo to local
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

#Install specified version for docker
sudo yum -y install docker-ce-"${docker_version}" docker-ce-cli-"${docker_version}" containerd.io

#Enable remote api functionality
sudo sed -i "s|ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock|ExecStart=/usr/bin/dockerd -H fd:// -H=tcp://0.0.0.0:2375|1" /usr/lib/systemd/system/docker.service

#Start docker first time to generate key.json
docker_hard_reset

sudo tee /etc/docker/daemon.json <<EOF
{
        "insecure-registries" : ["${scm_hostname}"]
}
EOF

#Hard reset docker service
docker_hard_reset

#Docker login to private scm
sudo docker login -u ${scm_user} -p ${scm_pwd} ${scm_hostname}

#Enable docker service
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

#Cleanup scripts
sudo rm -rf /home/build/docker_setup.sh
