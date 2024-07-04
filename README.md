# trojan-docker

## Obtain domain SSL certs

```sh
DOMAIN=trojan.pub
PASSWORD=u4D65CgC7KecFYAh

mkdir -p acme.sh
docker volume create --driver local --opt type=none --opt device=$PWD/acme.sh \
  --opt o=bind acme.sh
docker run -it --rm --name acme.sh -p 80:80 -v acme.sh:/root/.acme.sh \
  --entrypoint bash ghcr.io/ichuan/trojan-docker -c \
  "/etc/init.d/nginx start ; /root/.acme.sh/acme.sh --home /root/.acme.sh --issue --server letsencrypt -d $DOMAIN -w /var/www/html"
```
Certs will be renewed automatically.


## Running

```sh
docker run --restart always -itd --name trojan \
  -p 443:443 -p 80:80 -v acme.sh:/root/.acme.sh \
  -e DOMAIN=$DOMAIN -e PASSWORD=$PASSWORD ghcr.io/ichuan/trojan-docker
```
