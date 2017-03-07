## Notes
  * The "-j" flag initiates multi core building. This uses A LOT of RAM. If you don't have a lot of RAM, you need a lot of swap. If you don't have a lot of swap, don't build with multi core, or manually limit the amount of cores you use.
  * This sets the username and password to admin and admin in the event that no config file exists. Change this ASAP. Please.
  * This will generate an SSL cert if your config file does not exist - this should only ever happen on the first time
  * The expected behaviour is that your configs live in a volume - this is taken care of with the -v option in the docker create command below. It will map your "host" machine's /opt/dockerdata/znc folder to /znc-data
  * This build expects everything to be built with UID and GID 1000. If this is not the case, change your build file, or make a user on the host system that corresponds to these.
  * Make sure /opt/dockerdata/znc is owned by 1000:1000, or the machine won't start

## Basic Build Process

```bash
sudo docker build ./
sudo docker tag e413 znc-alpine:latest
sudo docker create \
  --name=znc \
  -v /opt/dockerdata/znc:/znc-data \
  -p 6501:6501 \
  znc-alpine
sudo docker start znc
# Need shell?
sudo docker exec -it znc /bin/sh
```
