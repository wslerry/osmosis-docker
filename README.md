# OSM to Mapforge

## Docker installation

### docker build

Building docker image

```shell
# build image using docker compose
docker compose build

# build image
docker build --rm -t lerryws/osmosis:latest .

# remove image
docker rmi lerryws/osmosis
```


Run command inside container

```shell
docker run -it --entrypoint bash lerryws/osmosis
```

### Usage

```shell
docker run -ti --rm -e OSM_SEA_FILE=sea.osm -e OSM_PBF_FILE=malaysia-singapore-brunei-latest.osm.pbf -v C:\Container_dev\osmosis_docker\osm\data:/data lerryws/osmosis
```

```shell
docker run -ti --rm -e JAVACMD_OPTIONS="-Xmx5g -Xms5g" -e OSM_SEA_FILE=sea.osm -e OSM_PBF_FILE=malaysia-singapore-brunei-latest.osm.pbf -v C:\Container_dev\osmosis_docker\osm\data:/data/input/ -v C:\Container_dev\osmosis_docker\output:/data/output/ lerryws/osmosis -a clip

docker run -ti --rm -e JAVACMD_OPTIONS="-Xmx5g -Xms5g" -e OSM_SEA_FILE=sea.osm -e OSM_PBF_FILE=malaysia-singapore-brunei-latest.osm.pbf -v C:\Container_dev\osmosis_docker\osm\data:/data/input/ -v C:\Container_dev\osmosis_docker\output:/data/output/ lerryws/osmosis -a merge

docker run -ti --rm -e JAVACMD_OPTIONS="-Xmx5g -Xms5g" -e OSM_SEA_FILE=sea.osm -e OSM_PBF_FILE=malaysia-singapore-brunei-latest.osm.pbf -v C:\Container_dev\osmosis_docker\osm\data:/data/input/ -v C:\Container_dev\osmosis_docker\output:/data/output/ lerryws/osmosis -a map
```

**Check changeset**

```
osmosis --read-xml file="planet1.osm" --read-xml file="planet2.osm" --derive-change --write-xml-change file="planetdiff-1-2.osc"
```
