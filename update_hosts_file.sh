#!/bin/bash
#set -x
#
echo "Enter cluster name:"
read cluster
echo "An IP address from the cluster:"
read IP
echo "We use sudo, so you might be asked for your computer password"
sudo sed -i '' "/${cluster}/d" /etc/hosts
echo "Enter remote server root password"
ssh -t root@${IP} "grep $cluster /etc/hosts" > ${cluster}_hosts
#echo "" | sudo tee -a /etc/hosts > /dev/null
echo "# ${cluster} Hosts" | sudo tee -a  /etc/hosts
cat ${cluster}_hosts | sudo tee -a  /etc/hosts
echo "#" | sudo tee -a  /etc/hosts
rm -f ${cluster}_hosts
