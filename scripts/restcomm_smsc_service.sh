#!/bin/bash

cqlsh 127.0.0.1 9042 -f /opt/Restcomm-SMSC/cassandra/cassandra.cql --cqlversion="3.4.2"
cqlsh 127.0.0.1 9042 -e "describe keyspaces;" --cqlversion="3.4.2"

/opt/Restcomm-SMSC/jboss-5.1.0.GA/bin/run.sh -b 0.0.0.0 -c simulator
