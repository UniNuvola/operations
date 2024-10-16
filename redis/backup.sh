#!/bin/bash

if [ -f common.sh ]; then source common.sh ; fi
if [ -f ../common.sh ]; then source ../common.sh ; fi

SERVICES_HOST=dipcont12
TODAY=`date +%Y-%m-%d`
UNINUVOLA_DIR=/root/uninuvola


IP=`ssh root@$SERVICES_HOST "cat $UNINUVOLA_DIR/redis/.env" | grep REDIS_IP | sed "s/REDIS_IP *=//"`
PASS=`ssh root@$SERVICES_HOST "cat $UNINUVOLA_DIR/redis/.env" | grep REDIS_PASSWORD | sed "s/REDIS_PASSWORD *=//"`
export REDISDUMPGO_AUTH=$PASS
redis-dump-go -host $IP -user default > $OPERATIONDIR/redis/data/redis-$TODAY.dump
