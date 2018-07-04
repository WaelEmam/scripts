#!/bin/bash

read  -p "Ambari Host:  " AMBARI_HOST
read -p "Port:  " PORT
read  -p "Ambari User:  " AMBARI_USER
echo "Ambari User Password:"
read -s AMBARI_PASSWD
read  -p "Cluster Name:  " CLUSER_NAME
#read  -p "Payload File:  " payload

# Get all Services
for i in $(curl -u $AMBARI_USER:$AMBARI_PASSWD -H "X-Requested-By: admin" -X GET http://$AMBARI_HOST:$PORT/api/v1/clusters/$CLUSER_NAME/services/| grep "service_name"| awk -F: '{print $2}'| awk -F\" '{print $2}')

do
if [ $i == "ZOOKEEPER" ]
then
echo "{\"RequestInfo\":{\"context\":\"${i} Service Check\",\"command\":\"${i}_QUORUM_SERVICE_CHECK\"},\"Requests/resource_filters\":[{\"service_name\":\"${i}\"}]}" > payload1
curl -u $AMBARI_USER:$AMBARI_PASSWD -H 'X-Requested-By: ambari' -X POST -d @payload1 http://$AMBARI_HOST:$PORT/api/v1/clusters/$CLUSER_NAME/requests

elif [ ${i} == "KERBEROS" ]
then
conrinue;
else 
echo "{\"RequestInfo\":{\"context\":\"${i} Service Check\",\"command\":\"${i}_SERVICE_CHECK\"},\"Requests/resource_filters\":[{\"service_name\":\"${i}\"}]}" > payload1

curl -u $AMBARI_USER:$AMBARI_PASSWD -H 'X-Requested-By: ambari' -X POST -d @payload1 http://$AMBARI_HOST:$PORT/api/v1/clusters/$CLUSER_NAME/requests
fi
done
rm -f payload1
