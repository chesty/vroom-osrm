#!/bin/bash

while [ ! -f /tmp/osrm-started ]; do
	sleep 1
done

: ${REFRESH:=0}
: ${SHAREDMEMORY:=0}

while (($#)); do
	if [ "$1" == "-s" ]; then
		SHAREDMEMORY=1

	elif [ "$1" == "-r" ]; then
		REFRESH=1
	fi
	shift
done

sed -ri -e 's/(var MAX_JOB_NUMBER =).*;/\1 500;/' /vroom-express/src/index.js

# https://github.com/docker/docker/issues/6880
mkfifo -m 600 /vroom-express/logpipe
chown www-data /vroom-express/logpipe
cat <> /vroom-express/logpipe 1>&2 &
ln -sf /vroom-express/logpipe /vroom-express/access.log
ln -sf /vroom-express/logpipe /vroom-express/error.log

if [ "$SHAREDMEMORY" != 0 ]; then
	sed -ri -e "s/(var USE_LIBOSRM =).*/\1 true;/" /vroom-express/src/index.js
	exec gosu www-data node /vroom-express/src/index.js
else
	sed -ri -e "s/(var USE_LIBOSRM =).*/\1 false;/" /vroom-express/src/index.js
	exec gosu www-data node /vroom-express/src/index.js
fi
