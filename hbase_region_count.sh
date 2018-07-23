#!/bin/bash
read  -p "Ambari Host:  " AMBARI_HOST
read -p "Port:  " PORT
read  -p "Ambari User:  " AMBARI_USER
echo "Ambari User Password:"
read -s AMBARI_PASSWD
read  -p "Cluster Name:  " CLUSER_NAME
read  -p "Ambari Metrics Host:  " AMBARI_METRICS_HOST

tot_num_reg=$(curl -s -X GET "$AMBARI_METRICS_HOST:3000/api/datasources/proxy/1/ws/v1/timeline/metrics?metricNames=regionserver.Server.regionCount._sum&hostname=&appId=hbase" | awk -F: '{print $9}' | awk -F\} '{print $1}')

tag_ver=$(curl -u $AMBARI_USER:$AMBARI_PASSWD -H 'X-Requested-By: ambari' -X GET "http://$AMBARI_HOST:$PORT/api/v1/clusters/$CLUSTER_NAME/configurations?type=hbase-env"| grep href| awk -F\" '{print$4}'| grep version| awk -F= '{print$3}')

rs_heap=$(curl -u $AMBARI_USER:$AMBARI_PASSWD -X GET "http://$AMBARI_HOST:$PORT/api/v1/clusters/$CLUSTER_NAME/configurations?type=hbase-env&tag=$tag_ver"| grep hbase_regionserver_heapsize| awk -F: '{print $2}'| awk -F\" '{print $2}')

memstore_flush=$(curl -u $AMBARI_USER:$AMBARI_PASSWD -X GET "http://$AMBARI_HOST:$PORT/api/v1/clusters/$CLUSTER_NAME/configurations?type=hbase-site&tag=$tag_ver" | grep memstore.flush| awk -F: '{print $2}'| awk -F\" '{print $2}')

memstore_fraction=$(curl -u $AMBARI_USER:$AMBARI_PASSWD -X GET "http://$AMBARI_HOST:$PORT/api/v1/clusters/$CLUSTER_NAME/configurations?type=hbase-site&tag=$tag_ver" | grep memstore.size | awk -F: '{print $2}'| awk -F\" '{print $2}')

RS_NUM=$(curl -u $AMBARI_USER:$AMBARI_PASSWD -X GET "http://$AMBARI_HOST:$PORT/api/v1/clusters/$CLUSTER_NAME/services/HBASE/components/HBASE_REGIONSERVER" | grep host_name | wc -l)

max_reg_t=$(echo "($rs_heap * $memstore_fraction) / ((($memstore_flush / 1024) / 1024)) * $RS_NUM" | bc -l) 
#echo $max_reg
max_reg=$(printf "%.1f" $max_reg_t)
if (( $(echo "$tot_num_reg > $max_reg" | bc -l ) ))
then
echo "WARNING: Total number of regions ($tot_num_reg) has exceeded regions Upper_limit ($max_reg)"
else
echo "Total number of regions is $tot_num_reg, its still safe. It should not exceed $max_reg"
fi
