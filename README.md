# ddclient-alpine
Get ddclient on alpine docker images

Example:
```
docker run \
       --rm \
       -ti \
       --net=host \
       -e "DYNU_USERNAME=<username>" \
       -e "DYNU_PASSWORD=<password>" \
       -e "DYNU_DOMAIN=<domain>" \
       -e "DYNU_SERVER=<server>" \
       -e "DYNU_DAEMON_OR_ONESHOT=oneshot" \
       -e "DYNU_AUTOPUBLIC_OR_INTERFACE=autopublic" \
       ```
