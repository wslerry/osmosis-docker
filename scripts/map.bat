
docker run -ti --rm -e JAVACMD_OPTIONS="-Xmx5g -Xms5g" \
-e OSM_SEA_FILE=sea.osm \
-e OSM_PBF_FILE=malaysia-singapore-brunei-latest.osm.pbf \
-v ${PWD}/data:/data/input/ \
-v ${PWD}/output:/data/output/ \
lerryws/osmosis map