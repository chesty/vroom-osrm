# crashbuggy/vroom-osrm
docker image for vroom and osrm

https://github.com/VROOM-Project/vroom
https://github.com/Project-OSRM/osrm-backend

I looked at a lot of existing docker projects and copied the bits that
suited me. 

the example systemd service unit configurations are pretty close to
how I run them. They require the systemd-docker package.
* https://github.com/chesty/vroom-osrm/blob/master/docker-osrm.service
* https://github.com/chesty/vroom-osrm/blob/master/docker-vroom.service

For persistent data, use a data container or a named volume, or do what 
I do and create an empty directory on your host file system 
```/home/docker/osm``` to mount inside the containers as a volume mount 
```/osm```

Then start the containers with the relevant environment variables set.
Here's the list of variables that affect the container starting with
some default settings.

For the container running osrm
* CPUS="4"
* DATA_PATH="/osm"
* OSM_PBF_URL="http://mirror2.shellbot.com/osm/planet-latest.osm.pbf"
* PROFILE="car"

For the container running vroom
* OSRM_HOST="osrm"

I added the supervisor package if you prefer to use it, but I run
osrm and vroom in separate containers atm. If you want to use supervisor
you can volume mount the supervisor configuration and run supervisor
instead of osrm.sh.

```
docker run --rm -ti --hostname osrm --name osrm \
    -v /home/docker/osm:/osm \
    -p 5000:5000 \
    -e CPUS=4 \
    -e DATA_PATH=/osm \
    -e OSM_PBF_URL=http://download.geofabrik.de/australia-oceania/australia-latest.osm.pbf \
    crashbuggy/vroom-osrm osrm.sh
```

the directory after : in -v /home/docker/osm:/osm (ie /osm) == DATA_PATH

for running vroom, OSRM_HOST is the --hostname of the container running 
osrm.sh

```
docker run --rm -ti --hostname vroom --name vroom \
    --volume /home/docker/osm:/osm \
    -p 3000:3000 \
    --env OSRM_HOST=osrm \
    crashbuggy/vroom-osrm vroom-express.sh
```
