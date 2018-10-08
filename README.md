![Docker Stars](https://img.shields.io/docker/stars/vanityshed/znc-alpine-push.svg)
![Docker PUlls](https://img.shields.io/docker/pulls/vanityshed/znc-alpine-push.svg)


## What is this?
This is the latest stable ZNC build running on Alpine 3.8 with current ZNC-Push master branch

## How do I run this?
Before you do anything, this example assumes you have created /opt/dockerdata/znc and run ''chown -R 1000:1000'' on that folder (or equivalent user you plan to use).
### Quick and simple
```bash
docker run --name=znc -v /opt/dockerdata/znc:/znc-data -p 6501:6501 vanityshed/znc-alpine-push:latest
```

This will run everything in the foreground, and will terminate when you exit:
```bash
root@alpine:~/znc-docker-alpine# docker run --name=znc -v /opt/dockerdata/znc:/znc-data -p 6501:6501 vanityshed/znc-alpine-push:latest
Doing nothing; conf exists
Checking for list of available modules...
Opening config [/znc-data/configs/znc.conf]...
Loading global module [webadmin]... [/opt/znc/lib/znc/webadmin.so]
Binding to port [+6501] using ipv4...
Loading user [admin]
Loading network [banter]
Loading network module [push]... [/znc-data/modules/push.so]
Adding server [irc.test.com 6667]...
Loading user module [chansaver]...
Loading user module [controlpanel]...
Staying open for debugging [pid: 9]
ZNC 1.6.5 - http://znc.in
```

### Slightly more permanent
```bash
docker create --name=znc -v /opt/dockerdata/znc:/znc-data -p 6501:6501 vanityshed/znc-alpine-push:latest
```

You will then need to start the container:
```bash
docker start znc
```

Confirm it is running:
```bash
root@alpine:~/znc-docker-alpine# docker ps -a
CONTAINER ID        IMAGE                               COMMAND                  CREATED             STATUS                      PORTS                    NAMES
214989732a9a        vanityshed/znc-alpine-push:latest   /docker-entrypoin...   5 seconds ago       Up 1 second                 0.0.0.0:6501->6501/tcp   znc
```


### Most permanent
Make yourself a docker-compose.yml file with the following contents:
```yaml
znc:
  image: 'vanityshed/znc-alpine-push:latest'
  restart: always
  ports:
    - '6501:6501'
  volumes:
    - '/opt/dockerdata/znc:/znc-data'
```

Then run in the same directory:
```bash
docker-compose up -d
```

## Notes
  * The "-j" flag initiates multi core building. This uses A LOT of RAM. If you don't have a lot of RAM, you need a lot of swap. If you don't have a lot of swap, don't build with multi core, or manually limit the amount of cores you use to 50% of your total, for example
  * This sets the username and password to admin and admin in the event that no config file exists. Change this ASAP. Please.
  * This will generate an SSL cert if your config file does not exist - this should only ever happen on the first time
  * The expected behaviour is that your configs live in a volume - this is taken care of with the -v option in the docker create command below. It will map your "host" machine's /opt/dockerdata/znc folder to /znc-data
  * This build expects everything to be built with UID and GID 1000. If this is not the case, change your build file, or make a user on the host system that corresponds to these.
  * Make sure /opt/dockerdata/znc is owned by 1000:1000, or the machine won't start

## Basic Build Process

```bash
sudo docker build -t znc-alpine ./
sudo docker create \
  --name=znc \
  -v /opt/dockerdata/znc:/znc-data \
  -p 6501:6501 \
  znc-alpine
sudo docker start znc
# Need shell?
sudo docker exec -it znc /bin/sh
```
