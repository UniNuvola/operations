#!/bin/bash

SERVICES_HOST=dipcont12
UNINUVOLA_DIR=/root/uninuvola

if [ -z "$1" ]; then
    TODAY=`date +%Y-%m-%d`
else
    TODAY=$1
fi

if [ ! -f redis-data/redis-$TODAY.dump ]; then
    echo "File redis-data/redis-$TODAY.dump not found"
    exit 1
fi

IP=`ssh root@$SERVICES_HOST "cat $UNINUVOLA_DIR/redis/.env" | grep REDIS_IP | sed "s/REDIS_IP *=//"`
PASS=`ssh root@$SERVICES_HOST "cat $UNINUVOLA_DIR/redis/.env" | grep REDIS_PASSWORD | sed "s/REDIS_PASSWORD *=//"`
export REDISCLI_AUTH=$PASS
echo "FLUSHALL" | redis-cli -h $IP
redis-cli -h $IP --pipe < redis-data/redis-$TODAY.dump
