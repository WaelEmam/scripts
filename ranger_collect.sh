#!/bin/bash

echo "#########################################"
echo "Please run this script on the Ranger Host"
echo "#########################################"

JAVA_HOME=$1

usage(){
        echo "Usage: ./range_collect.sh JAVA_HOME"
        exit 1
}

if [ $# -eq 0 ]
  then
    usage
fi

#read  -p "Ambari Host:  " AMBARI_HOST
#read -p "Port:  " PORT
#read  -p "Ambari User:  " AMBARI_USER
#echo "Ambari User Password:"
#read -s AMBARI_PASSWD
#read  -p "Cluster Name:  " CLUSER_NAME

AMBARI_HOST=172.25.36.13
PORT=8080
AMBARI_USER=admin
AMBARI_PASSWD=wemam
CLUSTER_NAME=c1150

# Variable Declarations
JAVA_HOME=$1
mkdir /tmp/HWX_RANGER_LOGS
LOG_DIR=/tmp/HWX_RANGER_LOGS
SCRIPT_LOG="$LOG_DIR/ranger_heap_dumps.log"

# Gather Ranger configs
tag_ver=$(curl -u admin:wemam -H 'X-Requested-By: ambari' -X GET "http://172.25.36.13:8080/api/v1/clusters/c1150/configurations?type=ranger-env" | grep tag |tail -1 | awk -F: '{print $2}'| awk -F\" '{print $2}')

range_admin_log_dir=$(curl -u admin:wemam -H 'X-Requested-By: ambari' -X GET "http://172.25.36.13:8080/api/v1/clusters/c1150/configurations?type=ranger-env&tag=$tag_ver"| grep ranger_admin_log_dir| awk -F : '{print $2}'| awk -F\, '{print $1}'| awk -F\" '{print $2}')

ranger_usersync_log_dir=$(curl -u admin:wemam -H 'X-Requested-By: ambari' -X GET "http://172.25.36.13:8080/api/v1/clusters/c1150/configurations?type=ranger-env&tag=$tag_ver"| grep ranger_usersync_log_dir| awk -F : '{print $2}'| awk -F\, '{print $1}'| awk -F\" '{print $2}')

ranger_pid_dir=$(curl -u admin:wemam -H 'X-Requested-By: ambari' -X GET "http://172.25.36.13:8080/api/v1/clusters/c1150/configurations?type=ranger-env&tag=$tag_ver"| grep ranger_pid_dir | awk -F : '{print $2}'| awk -F\, '{print $1}'| awk -F\" '{print $2}')

ranger_admin_pid=$(cat $ranger_pid_dir/rangeradmin.pid)

# Collect Logs
for i in $(ls -ltrh ${range_admin_log_dir}| grep xa_| tail -2 | awk '{ print $9}'| tr '\n' ' ')
do
   cp $range_admin_log_dir/$i $LOG_DIR
done

for i in $(ls -ltrh ${range_admin_log_dir}| grep cat| tail -2 | awk '{ print $9}'| tr '\n' ' ')
do
  cp $range_admin_log_dir/$i $LOG_DIR
done


#Take 4 thread dumps after heap dump
for i in {1..4} ; do
echo "Thread Dump #$i"
$JAVA_HOME/jstack -F $ranger_admin_pid >> $LOG_DIR/thread_dump.$i
sleep 60
done

# jstat

$JAVA_HOME/jstat -gcutil $ranger_admin_pid 1000 7 >> $LOG_DIR/jstat.out

# TOP Output
top -b -n 3 -d 15 >> $LOG_DIR/top_out

tar cf /tmp/${LOG_DIR}.tar /tmp/${LOG_DIR}
gzip /tmp/${LOG_DIR}.tar


echo "Please sent /tmp/${LOG_DIR}.tar.gz to Hortonworks"
