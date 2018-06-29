#!/bin/bash
set -x
DATE=`date +%Y-%m-%d.%H:%M:%S`
file="watch.out"
AMBARI_USER=admin
AMBARI_PASSWD=admin
AMBARI_HOST=<ambari_host>
CLUSER_NAME=<cluster_name>



if [ -f "$file" ]
then
gzip -S ".$DATE.gz" $file
fi

while true
do

for i in $(curl -u $AMBARI_USER:$AMBARI_PASSWORD -H 'X-Requested-By: ambari' -X GET "http://$AMBARI_HOST:8080/api/v1/clusters/$CLUSER_NAME/hosts"| grep host_name| egrep -v "%"| awk -F: '{print $2}' | awk -F \" '{print $2}')
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
