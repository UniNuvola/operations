#!/bin/bash

SERVICES_HOST=dipcont12
UNINUVOLA_DIR=/root/uninuvola

IP=`ssh root@$SERVICES_HOST "cat $UNINUVOLA_DIR/redis/.env" | grep REDIS_IP | sed "s/REDIS_IP *=//"`
PASS=`ssh root@$SERVICES_HOST "cat $UNINUVOLA_DIR/redis/.env" | grep REDIS_PASSWORD | sed "s/REDIS_PASSWORD *=//"`
export REDISCLI_AUTH=$PASS
redis-cli -h $IP
