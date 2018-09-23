#!/bin/bash
set -x
echo "Enter cluster name:"
read cluster
echo "An IP address from the cluster:"
read IP
sudo sed -i '' "/${cluster}/d" /etc/hosts
ssh -t root@${IP} 'grep c1150 /etc/hosts' > ${cluster}_hosts
#echo "" | sudo tee -a /etc/hosts > /dev/null
echo "# ${cluster} Hosts" | sudo tee -a  /etc/hosts
cat ${cluster}_hosts | sudo tee -a  /etc/hosts
