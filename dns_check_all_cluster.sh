#!/bin/bash

DATE=`date +%Y-%m-%d.%H:%M:%S`
file="watch.out"

read  -p "Ambari Host:  " AMBARI_HOST
read -p "Port:  " PORT
read  -p "Ambari User:  " AMBARI_USER
echo "Ambari User Password:"
read -s AMBARI_PASSWD
read  -p "Cluster Name:  " CLUSER_NAME

if [ -f "$file" ]
then
gzip -S ".$DATE.gz" $file
fi

while true
do

for i in $(curl -u $AMBARI_USER:$AMBARI_PASSWORD -H 'X-Requested-By: ambari' -X GET "http://$AMBARI_HOST:$PORT/api/v1/clusters/$CLUSER_NAME/hosts"| grep host_name| egrep -v "%"| awk -F: '{print $2}' | awk -F \" '{print $2}')
do
  echo "====================================" >> watch.out 2>&1
  echo $i  >> watch.out 2>&1
  nslookup $i  >> watch.out 2>&1
  echo "===================================="  >> watch.out 2>&1
  sleep 5
  echo $'\n' >> watch.out 2>&1

  count=$(egrep "server can't" watch.out | wc -l)

  if [ $count -gt 0 ]
  then
    echo "connection issue count:" ${count}
  fi
done

done
~
