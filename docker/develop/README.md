
Build de l'image docker local : 

```bash
docker build -t diaspora_ct . --build-arg DIA_UID=1001 --build-arg DIA_GID=1001

OR

../../script/diaspora-dev build --no-cache
```

```bash
../../script/diaspora-dev docker-compose up -d
```

Debug de l'entrypoint

```bash
sudo docker run -it diaspora-ct-broken /bin/bash --entrypoint=""
```

En local, en utilisant Tailscale, impossible d'utiliser certbot.

Utiliser la méthode DNS de letsencrypt depuis une autre machine, copier les certificats dans le volume letsencrypt

```bash
sudo docker cp /etc/letsencrypt diasporadev_reverse-proxy_1:/etc/letsencrypt
``` 