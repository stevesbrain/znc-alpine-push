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
