#!/usr/bin/env bash
set -x
read  -p "Ambari Host:  " AMBARI_HOST
read -p "Port:  " PORT
read  -p "Cluster Name:  " CLUSER_NAME
read  -p "Ambari User:  " AMBARI_USER
echo "Ambari User Password:"
read -s AMBARI_PASSWD


# Get all Services
#mkdir tmp
cp /dev/null tmp/host_components
curl -u $AMBARI_USER:$AMBARI_PASSWD -H "X-Requested-By: admin" -X GET http://$AMBARI_HOST:$PORT/api/v1/clusters/$CLUSER_NAME/services/| grep "service_name"| awk -F: '{print $2}'| awk -F\" '{print $2}' > tmp/services

while read services
do
    curl -u $AMBARI_USER:$AMBARI_PASSWD -H "X-Requested-By: admin" -X GET http://$AMBARI_HOST:$PORT/api/v1/clusters/$CLUSER_NAME/services/${services}/components | grep component_name| awk -F: '{print $2}'| awk -F\" '{print $2}' > tmp/${services}_components

    while read components
        do
        echo ${services}_${components} >> tmp/host_components
        echo "===========" >> tmp/test
        curl -u $AMBARI_USER:$AMBARI_PASSWD -H "X-Requested-By: admin" -X GET http://$AMBARI_HOST:$PORT/api/v1/clusters/$CLUSER_NAME/services/${services}/components/${components}?fields=host_components/HostRoles/host_name| grep "host_name"| grep -v "href"| awk -F: '{print $2}'| awk -F\" '{print $2}'>> tmp/host_components
        echo " " >>tmp/host_components
    done < tmp/${services}_components
done < tmp/services

