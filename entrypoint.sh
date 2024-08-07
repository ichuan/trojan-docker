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
  # fix acme.sh generating _ecc dir
  olddir="/root/.acme.sh/${DOMAIN}"
  [ -d "${olddir}_ecc" ] && {
    [ -s $olddir ] || {
      rm -rf ${olddir}.bak
      [ -d $olddir ] && mv $olddir ${olddir}.bak
      ln -s "${olddir}_ecc" $olddir
    }
  }
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
