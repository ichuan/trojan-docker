FROM debian:9
EXPOSE 443
WORKDIR /opt
ADD debian_9_sources.list /etc/apt/sources.list

RUN apt update && apt install -y wget cron socat nginx procps
RUN wget https://github.com/trojan-gfw/trojan/releases/download/v1.16.0/trojan-1.16.0-linux-amd64.tar.xz -O - | tar xJf -
RUN wget -O -  https://get.acme.sh | sh -s email=me@me.com

# cleanup
RUN apt autoremove -y && rm -rf /var/lib/apt/lists/*

COPY config.json entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
