#!/bin/bash

: ${CPUS:=1}
: ${OSM_PBF:=/osm/planet-latest.osm.pbf}
: ${OSM_PBF_URL:=http://mirror2.shellbot.com/osm/planet-latest.osm.pbf}
: ${DATA_PATH:=/osm}
: ${PROFILE:=car}

export CPUS OSM_PBF OSM_PBF_URL DATA_PATH PROFILE

cd $DATA_PATH

if [ ! -f "$OSM_PBF" -o "$1" == "REFRESH" ]; then
    curl -z "$OSM_PBF" -L \
            -o "$OSM_PBF" \
            "$OSM_PBF_URL"
fi

if [ ${OSM_PBF:(-8)} = ".osm.pbf" ]; then
    OSM_NAME=${OSM_PBF: 0:(-8)}
elif [ ${OSM_PBF:(-4)} = ".osm" ]; then
    OSM_NAME=${OSM_PBF: 0:(-4)}
fi

OSM_BASENAME=`basename $OSM_NAME`

if [ ! -d  ${DATA_PATH}/osrm/profiles ]; then
	mkdir -p ${DATA_PATH}/osrm
    cp -a /usr/local/share/osrm/profiles ${DATA_PATH}/osrm/
fi

if [ ! -e "${DATA_PATH}/osrm/processed/${PROFILE}/${OSM_BASENAME}.osrm"  -o "$1" == "REFRESH" ]; then
	mkdir -p "${DATA_PATH}/osrm/processed/${PROFILE}"
	cd "${DATA_PATH}/osrm/processed/${PROFILE}"
	echo "disk=${DATA_PATH}/stxxl,200000,syscall" > .stxxl
    osrm-extract $OSM_PBF -p "${DATA_PATH}/osrm/profiles/${PROFILE}.lua" -t $CPUS
    mv ${OSM_NAME}.osrm* .
    osrm-contract "${OSM_BASENAME}.osrm"
    rm -f ${DATA_PATH}/stxxl
fi

cd /
exec gosu www-data osrm-routed "${DATA_PATH}/osrm/processed/${PROFILE}/${OSM_BASENAME}.osrm" -t$CPUS -i0.0.0.0 -p5000
