# ddclient-alpine
Run [ddclient](https://sourceforge.net/p/ddclient/wiki/Home/) in an alpine docker container.
This'll update your [DDNS](https://en.wikipedia.org/wiki/Dynamic_DNS) provider with your
external IP address in the event that it changes.

## Usage

### Run with docker

```bash
docker run \
       --rm \
       -ti \
       --net=host \
       -e "DDNS_USERNAME=<username>" \
       -e "DDNS_PASSWORD=<password>" \
       -e "DDNS_DOMAIN=<domain>" \
       -e "DDNS_SERVER=<server>" \
       -e "DDNS_DAEMON_OR_ONESHOT=oneshot" \
       -e "DDNS_AUTOPUBLIC_OR_INTERFACE=autopublic" \
       -e "DDNS_CHECKIP_URL=checkip.dyndns.com" \
       -e "DDNS_DAEMON_REFRESH_INTERVAL=30" \
       zeva/ddclient-alpine
```

The `DDNS_CHECKIP_URL` and `DDNS_DAEMON_REFRESH_INTERVAL` environment variables are optional and will 
default to `checkip.dyndns.com` and `30` seconds respectively if not present.

The `DDNS_CHECKIP_URL` environment variable will be evaluated only if the
`DDNS_AUTOPUBLIC_OR_INTERFACE` variable is set to `autopublic`.

The `DDNS_DAEMON_REFRESH_INTERVAL` environment variable will be evaluated only if the
`DDNS_DAEMON_OR_ONESHOT` variable is set to `daemon`.

### Run with docker-compose

Clone this project and update all environment variable values in the `docker-compose.yml` file.
Then, from the directory that you cloned this project into, spin this image up by running the
following command:

```bash
docker-compose up -d
```

Verify that the container is running by issuing the following command and looking for a container called **ddclient**

```bash
docker-compose ps
```

Check the log output to verify that the ddclient script is actually attempting to update 
your DDNS provider by issuing the following command:

```bash
docker-compose logs --tail 200
```

Lastly, to tear the container down and toss it in the bin, try this command:

```bash
docker-compose down
```

## Image
This Docker image lives on the official Docker Hub at [zeva/ddclient-alpine](https://hub.docker.com/r/zeva/ddclient-alpine/)