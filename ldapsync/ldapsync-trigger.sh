#!/bin/bash

SERVICES_HOST=dipcont12
UNINUVOLA_DIR=/root/uninuvola

IP=`ssh root@$SERVICES_HOST "cat $UNINUVOLA_DIR/ldapsyncservice/.env" | grep LDAPSYNC_IP | sed "s/LDAPSYNC_IP *=//"`
curl http://$IP:8066
