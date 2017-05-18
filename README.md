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
       steasdal/ddclient-alpine
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

### Deploy to a Kubernetes cluster

You're going to want to know your way around Kubernetes to attempt this.  There are plenty of tutorials and 
instructional videos out there for those willing to Google 'em.  Give yourself a day or two to get up to speed.

1. Clone this project to a location where **kubectl** can get to it (on your Kubernetes master, for instance).
2. Update all of the environment variable values in the `deployment.yaml` file.
3. Update the `username` and `password` fields in the `secret.yaml` file with [Base64 Encoded](https://www.base64encode.org/)
   versions of your DDNS username and password.
4. Create the `ddclient-secret` to hold your username and password:
    ```bash
    kubectl create -f secret.yaml
    ```
5. Create the ddclient-alpine deployment:
    ```bash
    kubectl apply -f deployment.yaml
    ```

Boom!  Just like that, you should be up and running.  Here's a sprinkling of commands that you may want to know:

* `kubectl get all` - See all of the running bits of the deployment.
* `kubectl describe pod ddclient` - Get all of the juicy deets on the pod where the **ddclient-alpine** container is running.
* `kubectl describe secret ddclient-secret` - Verify that the **ddclient-secret** secret exists in your Kubernetes environment.
* `kubectl logs --tail 200 -lapp=ddclient` - Get the last 200 lines of the ddclient log.  Very useful for verifying that the
   ddclient service actually doing its job.
* `kubectl delete -f deploymet.yaml` - Shut down the deployment and delete all the bits 'n pieces.  You'll need to run this from
   the directory where you cloned this project (e.g. the directory where your modified `deployment.yaml` file is located).
* `kubectl delete -f secret.yaml` - Delete the ddclient-secret that holds your encoded username and password.  Again, you'll
   need to run this from the directory where your modified `secret.yaml` file resides.

Check out [This document](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/) for some
insight into what's going on under the covers and, in particular, what this "secret" business is all about.

## Image
This Docker image lives on the official Docker Hub at [steasdal/ddclient-alpine](https://hub.docker.com/r/steasdal/ddclient-alpine/)