#!/bin/sh

: ${CPUS:=1}
: ${OSM_PBF_URL:=http://mirror2.shellbot.com/osm/planet-latest.osm.pbf}
: ${DATA_PATH:=/osm}
: ${PROFILE:=car}
: ${REFRESH:=0}
: ${SHAREDMEMORY:=0}
: ${OSRM_HOST:=osrm}
: ${RENDERD_HOST:=tile.osm.org}
: ${VROOMEXPRESS_HOST:=localhost}

OSM_PBF=`basename $OSM_PBF_URL`
OSM_PBF="${DATA_PATH}/${OSM_PBF}"

export CPUS OSM_PBF_URL DATA_PATH PROFILE REFRESH SHAREDMEMORY OSM_PBF OSRM_HOST RENDERD_HOST VROOMEXPRESS_HOST

if [ $# -gt 0 ]; then
	exec $@
else
	exec /usr/bin/supervisord
fi
