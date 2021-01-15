#!/bin/sh

echo $@

/usr/bin/domoticz -approot /app \
	-dbase /config/domoticz.db \
	-noupdates  \
	-sslwww 1443  \
	-sslcert /config/server_cert.pem  \
	-userdata /config/ \
	$@

