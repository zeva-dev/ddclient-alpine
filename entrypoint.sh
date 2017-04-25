#!/bin/sh
set -e
CONF_FILE="/etc/ddclient.conf"
cp ${CONF_FILE}.original ${CONF_FILE}
mkdir -p /etc/ddclient/
mkdir -p /var/cache/ddclient/
ln -s /etc/ddclient.conf /etc/ddclient/ddclient.conf

: "${DYNU_DAEMON_OR_ONESHOT?Need to set DYNU_DAEMON_OR_ONESHOT env var for dynu}"
: "${DYNU_SERVER?Need to set DYNU_SERVER env var for dynu}"
: "${DYNU_USERNAME?Need to set DYNU_USERNAME env var for dynu}"
: "${DYNU_PASSWORD?Need to set DYNU_PASSWORD env var for dynu}"
: "${DYNU_DOMAIN?Need to set DYNU_DOMAIN env var for dynu}"
: "${DYNU_AUTOPUBLIC_OR_INTERFACE?Need to set DYNU_AUTOPUBLIC_OR_INTERFACE env var for dynu, chose autopublic, or a proper interface name such as eth0}"

if  [ "$DYNU_AUTOPUBLIC_OR_INTERFACE" = "autopublic" ]
then
    echo "use=web, web=checkip.dynu.com/, web-skip='IP Address'" >>  "${CONF_FILE}"
else
    INTERFACE_LIST=`cat /proc/net/dev | grep ":" | awk -F ":" '{print $1}' | awk '{$1=$1;print $1}'`
    result=`echo "${INTERFACE_LIST}" | grep "^${DYNU_AUTOPUBLIC_OR_INTERFACE}$" | wc -l`
    if ! [ "${result}" = "1" ]
    then
        echo "DYNU_AUTOPUBLIC_OR_INTERFACE should be set to autopublic or to one of the available interfaces"
        echo "$INTERFACE_LIST"
        exit
    fi
    echo "use=if, if=${DYNU_AUTOPUBLIC_OR_INTERFACE}" >>  "${CONF_FILE}"
fi

sed -i "s/SERVER/${DYNU_SERVER}/g" ${CONF_FILE}
sed -i "s/USERNAME/${DYNU_USERNAME}/g" ${CONF_FILE}
sed -i "s/PASSWORD/${DYNU_PASSWORD}/g" ${CONF_FILE}
echo "${DYNU_DOMAIN}" >>  "${CONF_FILE}"

if  [ "$DYNU_DAEMON_OR_ONESHOT" = "daemon" ]
then
    echo "daemon=60" >> ${CONF_FILE}
    ddclient -foreground -verbose -daemon=30
elif [ "$DYNU_DAEMON_OR_ONESHOT" = "oneshot" ]
then
    ddclient -foreground -verbose -daemon=0
else
    echo "DYNY_DAEMON_OR_ONESHOT should be set to daemon or to oneshot"
fi

