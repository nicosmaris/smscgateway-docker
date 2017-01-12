#!/bin/bash

function jsonval {
    temp=`cat /etc/container_environment.json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $1`
    if [ $? -eq 0 ];then
    IFS=':' read ar1 ar2 <<<$temp
    echo "$ar2 > /etc/container_environment/$ar1"
    echo -e "$ar2" | xargs > /etc/container_environment/$ar1

    fi
}

## declare an array variable
vars="ENVCONFURL
CASSANDRA_IP
SMSC_SERVER
STATIC_ADDRESS"

for variable in $vars  # Note: No quotes
do
  jsonval $variable
done

