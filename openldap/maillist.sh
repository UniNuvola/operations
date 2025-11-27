#!/bin/bash
. ./info.sh > /dev/null
ldapsearch -H ldap://$IP -b "dc=uninuvola,dc=unipg,dc=it" -LLL "mail=*" mail -x -D "cn=admin,dc=uninuvola,dc=unipg,dc=it" -w $PASS | grep "mail: " | sed "s/mail: *//"
