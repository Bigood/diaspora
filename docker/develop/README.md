
Build de l'image docker local : 

```bash
docker build -t diaspora_ct . --build-arg DIA_UID=1001 --build-arg DIA_GID=1001

OR

../../scripts/diaspora-dev build --no-cache
```

```bash
../../scripts/diaspora-dev docker-compose up -d
```

Debug de l'entrypoint

```bash
sudo docker run -it diaspora-ct-broken /bin/bash --entrypoint=""
```