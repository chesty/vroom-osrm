#!/bin/bash

cd $DATA_PATH

if [ ! -d "${DATA_PATH}/vroom-osrm-pre.d" ]; then
	rm -f "${DATA_PATH}/vroom-osrm-pre.d"
	mkdir "${DATA_PATH}/vroom-osrm-pre.d"
fi

if [ ! -d "${DATA_PATH}/vroom-osrm-post.d" ]; then
	rm -f "${DATA_PATH}/vroom-osrm-post.d"
	mkdir "${DATA_PATH}/vroom-osrm-post.d"
fi


if [ ! -f "$OSM_PBF" -o "$REFRESH" != 0 ]; then
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

if [ ! -e "${DATA_PATH}/osrm/processed/${PROFILE}/${OSM_BASENAME}.osrm"  -o "$REFRESH" != 0 ]; then
	rm -rf "${DATA_PATH}/osrm/processed/${PROFILE}"
	mkdir -p "${DATA_PATH}/osrm/processed/${PROFILE}"
	cd "${DATA_PATH}/osrm/processed/${PROFILE}"
	echo "disk=${DATA_PATH}/stxxl,200000,syscall" > .stxxl
    osrm-extract $OSM_PBF -p "${DATA_PATH}/osrm/profiles/${PROFILE}.lua" -t $CPUS
    mv ${OSM_NAME}.osrm* .
    osrm-contract "${OSM_BASENAME}.osrm"
    rm -f ${DATA_PATH}/stxxl
fi

cd /
if [ "$SHAREDMEMORY" != 0 ]; then
	gosu www-data osrm-datastore "${DATA_PATH}/osrm/processed/${PROFILE}/${OSM_BASENAME}.osrm"
	exec gosu www-data osrm-routed --shared-memory on -t$CPUS -i0.0.0.0 -p5000
else
	exec gosu www-data osrm-routed "${DATA_PATH}/osrm/processed/${PROFILE}/${OSM_BASENAME}.osrm" -t$CPUS -i0.0.0.0 -p5000
fi
