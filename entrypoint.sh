#!/usr/bin/env bash

envs=(PASSWORD DOMAIN)

if test $# -eq 0; then
  for i in ${envs[@]}; do
    if test -z "${!i}"; then
      echo "Missing env variable: $i"
      exit 1
    fi
    export $i
  done
  # cron
  printenv | grep -v no_proxy > /etc/environment
  /etc/init.d/cron start
  (crontab -l | grep -v pkill; echo "0 1 * * * pkill --signal SIGUSR1 --exact trojan") | crontab -
  # nginx
  /etc/init.d/nginx start
  # change acme.sh from standalone mode to webroot mode
  sed -i -e "s#Le_Webroot='no'#Le_Webroot='/var/www/html'#g" /root/.acme.sh/${DOMAIN}/${DOMAIN}.conf
  # limits
  sysctl fs.file-max=6553560 2>/dev/null
  [ -f /etc/systemd/system.conf ] && sed -i "s/^#DefaultLimitNOFILE=.*/DefaultLimitNOFILE=500000/g" /etc/systemd/system.conf
  echo -e "* soft nofile 500000\n* hard nofile 500000\nroot soft nofile 500000\nroot hard nofile 500000" > /etc/security/limits.conf 2>/dev/null
  # config
  sed -i -e "s#{domain}#$DOMAIN#g" -e "s/{password}/${PASSWORD}/g" /config.json
  # trojan
  exec /opt/trojan/trojan -c /config.json
else
  exec $@
fi
