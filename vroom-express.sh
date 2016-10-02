#!/bin/bash

sed -ri -e 's/(var MAX_JOB_NUMBER =).*;/\1 500;/' \
        -e "s/(var USE_LIBOSRM =).*/\1 true;/" /vroom-express/src/index.js

# https://github.com/docker/docker/issues/6880
mkfifo -m 600 /vroom-express/logpipe
chown www-data /vroom-express/logpipe
cat <> /vroom-express/logpipe 1>&2 &
ln -sf /vroom-express/logpipe /vroom-express/access.log
ln -sf /vroom-express/logpipe /vroom-express/error.log

exec gosu www-data node /vroom-express/src/index.js
