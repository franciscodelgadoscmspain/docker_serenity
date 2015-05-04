#!/bin/bash

DESTDIR=$1
HOSTHTTPDCONF=/etc/httpd/conf
source  ~/.src_conf 2> /dev/null

if [ -r $HOSTHTTPDCONF/ssl.crt/server.crt -a -r $HOSTHTTPDCONF/ssl.key/server.key ] ; then
   if [ -r $HOSTHTTPDCONF/ssl.crt/ca.crt ] ; then
	cp $HOSTHTTPDCONF/ssl.crt/ca.crt $DESTDIR/conf/
   fi
   cp $HOSTHTTPDCONF/ssl.crt/server.crt $DESTDIR/conf/
   cp $HOSTHTTPDCONF/ssl.key/server.key $DESTDIR/conf/
else
echo "There is no host certificate on this server, generating my own"

#IP_NUMBER_ETH0=$(/sbin/ifconfig eth0 | sed -n 's/.*inet addr:\([^\ ]*\).*/\1/p')
ISSUER=$USER.$(date +%s)

openssl genrsa -des3 -passout pass:pass 512 > $DESTDIR/conf/server.key 2> /dev/null
openssl req -passin pass:pass -new -key $DESTDIR/conf/server.key -x509 -days 14 -out $DESTDIR/conf/server.crt > /dev/null 2>&1 << EOF
SE
Bonkaland
Bonkacity
$ISSUER

$REGRESS_HOSTNAME

EOF
openssl rsa -in $DESTDIR/conf/server.key -passin pass:pass -out $DESTDIR/conf/server.key > /dev/null 2>&1 
fi
