# Setup
Après avoir modifié les fichiers de conf (mettre l'host mysql ou pogresql à la place de localhost dans database.yml notamment)

```bash
# setup initial (build config bundle setup_rails setup_tests)
../../script/diaspora-dev setup
# création base de données
../../script/diaspora-dev migrate
# deps front
../../script/diaspora-dev yarn
# lancement
../../script/diaspora-dev docker-compose up -d
```

# Alternative

Build de l'image docker local : 

```bash
docker build -t diaspora_ct . --build-arg DIA_UID=1001 --build-arg DIA_GID=1001

OR

../../script/diaspora-dev build --no-cache
```

```bash
../../script/diaspora-dev docker-compose up -d
```

# Debug de l'entrypoint

```bash
sudo docker run -it diaspora-ct-broken /bin/bash --entrypoint=""
```

# Tailscale

En local, en utilisant Tailscale, impossible d'utiliser certbot.

Utiliser la méthode DNS de letsencrypt depuis une autre machine, copier les certificats dans le volume letsencrypt

```bash
sudo certbot certonly --manual --preferred-challenges dns -d URL -m MAIL@DN.COM --agree-tos
sudo docker cp /etc/letsencrypt diasporadev_reverse-proxy_1:/etc/letsencrypt
``` 

# Troubleshooting

## Erreur au lancement 
Attention aux droits d'user sur le dossier /diaspora, créé par docker.

Faut que ce soit diaspora:diaspora (1001:1001), avec du +x partout.

```log
I, [2022-12-06T15:23:59.168469 #19]  INFO -- : [diaspora:web] load_external_pid_file: pid_file not found
I, [2022-12-06T15:23:59.213775 #19]  INFO -- : [diaspora:web] switch :starting [:unmonitored => :starting] monitor by user
I, [2022-12-06T15:23:59.233142 #19]  INFO -- : [diaspora:web] daemonizing: `bin/puma -C config/puma.rb` with start_grace: 2.5s, env: 'RAILS_ENV=development', <> (in /diaspora)
E, [2022-12-06T15:23:59.233285 #19] ERROR -- : [diaspora:web] daemonize failed with #<Errno::EACCES: Permission denied - bin/puma>
E, [2022-12-06T15:23:59.233318 #19] ERROR -- : [diaspora:web] process <> failed to start ("#<Errno::EACCES: Permission denied - bin/puma>")
I, [2022-12-06T15:23:59.233989 #19]  INFO -- : [diaspora:web] switch :crashed [:starting => :down] monitor by user
I, [2022-12-06T15:23:59.234718 #19]  INFO -- : [diaspora:web] schedule :check_crash (crashed)
I, [2022-12-06T15:23:59.234768 #19]  INFO -- : [diaspora:web] <= monitor
I, [2022-12-06T15:23:59.234790 #19]  INFO -- : [diaspora:web] => check_crash  (crashed)
W, [2022-12-06T15:23:59.234825 #19]  WARN -- : [diaspora:web] check crashed: process is down
I, [2022-12-06T15:23:59.234870 #19]  INFO -- : [diaspora:web] schedule :restore (crashed)
I, [2022-12-06T15:23:59.234916 #19]  INFO -- : [diaspora:web] <= check_crash
I, [2022-12-06T15:23:59.234938 #19]  INFO -- : [diaspora:web] => restore  (crashed)
```

## Pas de CSS ni js front end

Configurer ça en dev dans le toml :

```yml
[configuration.environment.assets]
serve = true
```

ou bien 

`RAILS_ENV=production bundle exec rake tmp:cache:clear assets:precompile`