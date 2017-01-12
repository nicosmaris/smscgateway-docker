#!/bin/bash

LATEST_LOGS_DIR=$(\ls -1dt /var/log/restcomm*/ | head -n 1)

for f in $LATEST_LOGS_DIR/host/*
do
  echo "Log file: $f"
  cat $f
done
