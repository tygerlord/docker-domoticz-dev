#!/bin/sh

/usr/bin/domoticz \ 
	-approot /usr/share/domoticz \
	-dbase /config/domoticz.db \
	-noupdate  \
	-sslwww 1443  \
	-sslcert /config/server_cert.pem  \
	-userdata /config/ 

