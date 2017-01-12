#!/bin/bash

echo -e "127.0.0.1" > /etc/container_environment/CASSANDRA_IP
echo -e "0.0.0.0" > /etc/container_environment/STATIC_ADDRESS
echo -e "simulator" > /etc/container_environment/SMSC_SERVER
