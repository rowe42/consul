#!/bin/sh -x

#USER_UID=$(stat -c %u /var/www/consul/Gemfile)
#USER_GID=$(stat -c %g /var/www/consul/Gemfile)

#export USER_UID
#export USER_GID

#usermod -u "$USER_UID" consul 2> /dev/null

#groupmod -g "$USER_GID" consul 2> /dev/null
#groupmod -g "$USER_GID" root 2> /dev/null
#usermod -g "$USER_GID" consul 2> /dev/null

#usermod -g root consul 2> /dev/null

#chown -R -h "$USER_UID" "$BUNDLE_PATH"
#chgrp -R -h "$USER_GID" "$BUNDLE_PATH"
#chown -R -h "$USER_UID" /var/www/consul
#chgrp -R -h root /var/www/consul


#/usr/bin/sudo -EH -u consul "$@"
#"$@"
rm /var/www/consul/tmp/pids/server.pid
bundle exec rails s -p 3000 -b 0.0.0.0
