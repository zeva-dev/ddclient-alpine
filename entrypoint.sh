#!/bin/sh
set -e
CONF_FILE="/etc/ddclient.conf"
cp ${CONF_FILE}.original ${CONF_FILE}
mkdir -p /etc/ddclient/
mkdir -p /var/cache/ddclient/
ln -s /etc/ddclient.conf /etc/ddclient/ddclient.conf

: "${DDNS_DAEMON_OR_ONESHOT?Need to set DDNS_DAEMON_OR_ONESHOT env var}"
: "${DDNS_SERVER?Need to set DDNS_SERVER env var}"
: "${DDNS_USERNAME?Need to set DDNS_USERNAME env var}"
: "${DDNS_PASSWORD?Need to set DDNS_PASSWORD env var}"
: "${DDNS_DOMAIN?Need to set DDNS_DOMAIN env var}"
: "${DDNS_AUTOPUBLIC_OR_INTERFACE?Need to set DDNS_AUTOPUBLIC_OR_INTERFACE env var, chose autopublic, or a proper interface name such as eth0}"

CHECKIP_URL=${DDNS_CHECKIP_URL:-checkip.dyndns.com}

if  [ "$DDNS_AUTOPUBLIC_OR_INTERFACE" = "autopublic" ]
then
    echo "use=web, web=checkip.dyndns.com/, web-skip='IP Address'" >> "${CONF_FILE}"
    #echo "use=web, web=checkip.dynu.com/, web-skip='IP Address'" >>  "${CONF_FILE}"
else
    INTERFACE_LIST=`cat /proc/net/dev | grep ":" | awk -F ":" '{print $1}' | awk '{$1=$1;print $1}'`
    result=`echo "${INTERFACE_LIST}" | grep "^${DDNS_AUTOPUBLIC_OR_INTERFACE}$" | wc -l`
    if ! [ "${result}" = "1" ]
    then
        echo "DDNS_AUTOPUBLIC_OR_INTERFACE should be set to autopublic or to one of the available interfaces"
        echo "$INTERFACE_LIST"
        exit
    fi
    echo "use=if, if=${DDNS_AUTOPUBLIC_OR_INTERFACE}" >>  "${CONF_FILE}"
fi

sed -i "s/SERVER/${DDNS_SERVER}/g" ${CONF_FILE}
sed -i "s/USERNAME/${DDNS_USERNAME}/g" ${CONF_FILE}
sed -i "s/PASSWORD/${DDNS_PASSWORD}/g" ${CONF_FILE}
echo "${DDNS_DOMAIN}" >>  "${CONF_FILE}"

# Set the daemon refresh interval if the expected environment
# variable is present; default to 30 seconds if it's not.
DAEMON_REFRESH_INTERVAL=${DDNS_DAEMON_REFRESH_INTERVAL:-30}

if  [ "$DDNS_DAEMON_OR_ONESHOT" = "daemon" ]
then
    echo "daemon=$DAEMON_REFRESH_INTERVAL" >> ${CONF_FILE}
    ddclient -foreground -verbose -debug -daemon=$DAEMON_REFRESH_INTERVAL
elif [ "$DDNS_DAEMON_OR_ONESHOT" = "oneshot" ]
then
    ddclient -foreground -verbose -debug -daemon=0
else
    echo "DDNS_DAEMON_OR_ONESHOT should be set to daemon or to oneshot"
fi

