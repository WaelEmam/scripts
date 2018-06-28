#!/bin/bash

DATE=`date +%Y-%m-%d.%H:%M:%S`
file="watch.out"

usage(){
        echo "Usage: ./trace.sh <Host FQDN>"
        exit 1
}

if [ $# -eq 0 ]
  then
    usage
fi


if [ -f "$file" ]
then
gzip -S ".$DATE.gz" $file
fi

while true
do
  echo "====================================" >> watch.out 2>&1
  echo $1  >> watch.out 2>&1
  nslookup $1  >> watch.out 2>&1
  echo "===================================="  >> watch.out 2>&1
  sleep 5
  echo $'\n' >> watch.out 2>&1
  
  count=$(egrep "server can't" watch.out | wc -l)
  
  if [ $count -gt 0 ]
  then
    echo "connection issue count:" ${count}
  fi
 done
~
