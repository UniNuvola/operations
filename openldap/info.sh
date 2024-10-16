#!/bin/bash

if [ -f common.sh ]; then source common.sh ; fi
if [ -f ../common.sh ]; then source ../common.sh ; fi

SERVICES_HOST=dipcont12
UNINUVOLA_DIR=/root/uninuvola

IP=`ssh root@$SERVICES_HOST "cat $UNINUVOLA_DIR/openLDAP/.env" | grep LDAP_IP | sed "s/LDAP_IP *=//"`
PASS=`ssh root@$SERVICES_HOST "cat $UNINUVOLA_DIR/openLDAP/.env" | grep ADMIN_PASSWORD | sed "s/ADMIN_PASSWORD *=//"`
echo "IP: $IP"
echo "PASSWORD: $PASS"
