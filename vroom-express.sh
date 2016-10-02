#!/bin/bash

: ${OSRM_HOST:=osrm}

export OSRM_HOST

sed -ri -e 's/(var MAX_JOB_NUMBER =).*;/\1 500;/' \
        -e "s/(var OSRM_ADDRESS =).*/\1 \"${OSRM_HOST}\";/" /vroom-express/src/index.js


# https://github.com/docker/docker/issues/6880
mkfifo -m 600 /vroom-express/logpipe
chown www-data /vroom-express/logpipe
cat <> /vroom-express/logpipe 1>&2 &
ln -sf /vroom-express/logpipe /vroom-express/access.log
ln -sf /vroom-express/logpipe /vroom-express/error.log

exec gosu www-data node /vroom-express/src/index.js
