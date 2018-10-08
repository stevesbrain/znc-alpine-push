#!/bin/sh

if [ "${1:0:1}" != '-' ]; then
    exec "$@"
fi

mkdir -p /znc-data/configs
mkdir -p /znc-data/moddata
mkdir -p /znc-data/users
mkdir -p /znc-data/modules
cp /docker/modules/*.so /znc-data/modules/

if [ -e /znc-data/configs/znc.conf ]; then
    echo "Doing nothing; conf exists"
  else
	  /opt/znc/bin/znc -p -d /znc-data/ 
	  cp /docker/znc.conf.example /znc-data/configs/znc.conf
fi
    

DATADIR="/znc-data"

if [ -r /znc-build-modules.sh ]; then
    source /znc-build-modules.sh || exit 3
fi

cd /

exec /sbin/tini -- /opt/znc/bin/znc --foreground --datadir "$DATADIR" "$@"
