# crashbuggy/vroom-osrm
docker image for vroom and osrm

https://github.com/VROOM-Project/vroom
https://github.com/Project-OSRM/osrm-backend

I looked at a lot of existing docker projects and copied the bits that
suited me. 

the example systemd service unit configurations are pretty close to
how I run them. They require the systemd-docker package.
you can use both docker-osrm.service and docker-vroom.service to run
them in separate containers, alternatively run docker-vroom-osrm.service 
by itself to run both osrm-routed and vroom-express in the one container 
using supervisor with optional shared memory support (enabled in the 
example)
* https://github.com/chesty/vroom-osrm/blob/master/docker-osrm.service
* https://github.com/chesty/vroom-osrm/blob/master/docker-vroom.service
* https://github.com/chesty/vroom-osrm/blob/master/docker-vroom-osrm.service

For persistent data, use a data container or a named volume, or do what 
I do and create an empty directory on your host file system 
`/home/docker/osm` to mount inside the containers as a volume mount `/osm`

Then start the containers with the relevant environment variables set.
Here's the list of variables that affects the container with
some example settings.

For the container running osrm
* CPUS="4"
* DATA_PATH="/osm"
* OSM_PBF_URL="http://mirror2.shellbot.com/osm/planet-latest.osm.pbf"
* PROFILE="car"
* REFRESH="0"

For the container running vroom
* OSRM_HOST="osrm"

For the vroom and osrm in the one container using supervisor
* CPUS="4"
* DATA_PATH="/osm"
* OSM_PBF_URL="http://mirror2.shellbot.com/osm/planet-latest.osm.pbf"
* PROFILE="car"
* SHAREDMEMORY="1"
* REFRESH="0"

Setting REFRESH="1" will cause the osm data to be re-downloaded and
osrm data to be regenerated.

Here's some examples, the first is to run both osrm-routed and vroom in
the one container using shared memory

```
docker run --rm -ti --hostname osrm --name osrm 
    --network-alias vroom \
    -v /home/docker/osm:/osm \
    -p 5000:5000 \
    -p 3000:3000 \
    -e CPUS=4 \
    -e DATA_PATH=/osm \
    -e OSM_PBF_URL=http://download.geofabrik.de/australia-oceania/australia-latest.osm.pbf \
    -e SHAREDMEMORY=1 \
    crashbuggy/vroom-osrm
```

the directory after : in -v /home/docker/osm:/osm (ie /osm) == DATA_PATH

To run just osrm

```
docker run --rm -ti --hostname osrm --name osrm \
    -v /home/docker/osm:/osm \
    -p 5000:5000 \
    -e CPUS=4 \
    -e DATA_PATH=/osm \
    -e OSM_PBF_URL=http://download.geofabrik.de/australia-oceania/australia-latest.osm.pbf \
    crashbuggy/vroom-osrm osrm.sh
```

for running vroom, OSRM_HOST is the --hostname of the container running 
osrm.sh

```
docker run --rm -ti --hostname vroom --name vroom \
    --volume /home/docker/osm:/osm \
    -p 3000:3000 \
    --env OSRM_HOST=osrm \
    crashbuggy/vroom-osrm vroom-express.sh
```

