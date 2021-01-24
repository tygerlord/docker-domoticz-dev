#!/bin/bash

echo $@


# https://github.com/pipiche38/Domoticz-Zigate-Wiki/blob/master/en-eng/PiZigate-RPI3B%2B-Cookbook.md
PLUGINS_DIR="/config/plugins"
ZIGATE_DIR="$PLUGIN_DIR/Zigate"
ZIGATE_TOOLS="$ZIGATE_DIR/Tools"

ZIGATE_TEST_TOOL="$ZIGATE_DIR/Tools/PiZiGate-tools"

if [ -d "$PLUGINS_DIR" ]; then
  echo "Check install plugin zigate "
  if [ ! -d "$ZIGATE_DIR" ]; then
     pushd "$PLUGINS_DIR"
     git clone https://github.com/pipiche38/Domoticz-Zigate
     popd
  fi
  if [ -d "$ZIGATE_TOOLS"  -a ! -d "$ZIGATE_TOOLS/PiZiGate-tools" ]; then
     pushd "$ZIGATE_TOOLS"
     git clone https://github.com/fairecasoimeme/PiZiGate-tools.git
     cd PiZiGate-tools/test	
     make
  fi
fi


#mode run
$ZIGATE_DIR/Tools/pi-zigate.sh run || echo "configuration mistake ?"

#start domoticz
/usr/bin/domoticz -approot /app \
	-dbase /config/domoticz.db \
	-noupdates  \
	-sslwww 1443  \
	-sslcert /config/server_cert.pem  \
	-userdata /config/ \
	$@

