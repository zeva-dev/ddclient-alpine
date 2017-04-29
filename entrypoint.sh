#!/bin/sh
set -e
CONF_FILE="/etc/ddclient.conf"
cp ${CONF_FILE}.original ${CONF_FILE}
mkdir -p /etc/ddclient/
mkdir -p /var/cache/ddclient/
ln -s /etc/ddclient.conf /etc/ddclient/ddclient.conf

: "${DDS_DAEMON_OR_ONESHOT?Need to set DDS_DAEMON_OR_ONESHOT env var}"
: "${DDS_SERVER?Need to set DDS_SERVER env var}"
: "${DDS_USERNAME?Need to set DDS_USERNAME env var}"
: "${DDS_PASSWORD?Need to set DDS_PASSWORD env var}"
: "${DDS_DOMAIN?Need to set DDS_DOMAIN env var}"
: "${DDS_AUTOPUBLIC_OR_INTERFACE?Need to set DDS_AUTOPUBLIC_OR_INTERFACE env var, chose autopublic, or a proper interface name such as eth0}"

if  [ "$DDS_AUTOPUBLIC_OR_INTERFACE" = "autopublic" ]
then
    echo "use=web, web=checkip.dyndns.com/, web-skip='IP Address'" >> "${CONF_FILE}"
    #echo "use=web, web=checkip.dynu.com/, web-skip='IP Address'" >>  "${CONF_FILE}"
else
    INTERFACE_LIST=`cat /proc/net/dev | grep ":" | awk -F ":" '{print $1}' | awk '{$1=$1;print $1}'`
    result=`echo "${INTERFACE_LIST}" | grep "^${DDS_AUTOPUBLIC_OR_INTERFACE}$" | wc -l`
    if ! [ "${result}" = "1" ]
    then
        echo "DDS_AUTOPUBLIC_OR_INTERFACE should be set to autopublic or to one of the available interfaces"
        echo "$INTERFACE_LIST"
        exit
    fi
    echo "use=if, if=${DDS_AUTOPUBLIC_OR_INTERFACE}" >>  "${CONF_FILE}"
fi

sed -i "s/SERVER/${DDS_SERVER}/g" ${CONF_FILE}
sed -i "s/USERNAME/${DDS_USERNAME}/g" ${CONF_FILE}
sed -i "s/PASSWORD/${DDS_PASSWORD}/g" ${CONF_FILE}
echo "${DDS_DOMAIN}" >>  "${CONF_FILE}"

if  [ "$DDS_DAEMON_OR_ONESHOT" = "daemon" ]
then
    echo "daemon=60" >> ${CONF_FILE}
    ddclient -foreground -verbose -daemon=30
elif [ "$DDS_DAEMON_OR_ONESHOT" = "oneshot" ]
then
    ddclient -foreground -verbose -daemon=0
else
    echo "DDS_DAEMON_OR_ONESHOT should be set to daemon or to oneshot"
fi

