#!/bin/bash
#
# Starts SMSC as jboss

echo "CASSANDRA_IP: ${CASSANDRA_IP:="127.0.0.1"}"
# jboss currently uses localhost instead of the CASSANDRA_IP env var
echo "STATIC_ADDRESS: ${STATIC_ADDRESS:="0.0.0.0"}"
echo "SMSC_SERVER: ${SMSC_SERVER:="simulator"}"

cqlsh $CASSANDRA_IP 9042 -f /opt/Restcomm-SMSC/cassandra/cassandra.cql --cqlversion="3.4.2"
cqlsh $CASSANDRA_IP 9042 -e "describe keyspaces;" --cqlversion="3.4.2"

/opt/Restcomm-SMSC/jboss-5.1.0.GA/bin/run.sh -b $STATIC_ADDRESS -c $SMSC_SERVER
