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
cp /dev/null tmp/test
curl -u $AMBARI_USER:$AMBARI_PASSWD -H "X-Requested-By: admin" -X GET http://$AMBARI_HOST:$PORT/api/v1/clusters/c2150/services/| grep "service_name"| awk -F: '{print $2}'| awk -F\" '{print $2}' > tmp/services

while read y
do
    curl -u $AMBARI_USER:$AMBARI_PASSWD -H "X-Requested-By: admin" -X GET http://$AMBARI_HOST:$PORT/api/v1/clusters/c2150/services/${y}/components | grep component_name| awk -F: '{print $2}'| awk -F\" '{print $2}' > tmp/${y}_components

    while read x
        do
        echo ${y}_${x} >> tmp/test
        echo "===========" >> tmp/test
        curl -u $AMBARI_USER:$AMBARI_PASSWD -H "X-Requested-By: admin" -X GET http://$AMBARI_HOST:$PORT/api/v1/clusters/c2150/services/${y}/components/${x}?fields=host_components/HostRoles/host_name| grep "host_name"| grep -v "href"| awk -F: '{print $2}'| awk -F\" '{print $2}'>> tmp/test
        echo " " >>tmp/test
    done < tmp/${y}_components
done < tmp/services

