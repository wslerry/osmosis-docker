#!/bin/bash
(set -o ignr) 2>/dev/null && set -o igncr;

figlet -t "OSM To Mapforge"

JAVACMD_OPTIONS="${JAVACMD_OPTIONS:=-Xmx1g -Xms1g}"

: "${INPUT_DATA_DIR:=/data/input}"
: "${OUTPUT_DATA_DIR:=/data/output}"

# Ensure the input directory exists
if [ ! -d "$INPUT_DATA_DIR" ]; then
    echo "Creating input directory: $INPUT_DATA_DIR"
    mkdir -p "$INPUT_DATA_DIR"
fi

# Ensure the output directory exists
if [ ! -d "$OUTPUT_DATA_DIR" ]; then
    echo "Creating output directory: $OUTPUT_DATA_DIR"
    mkdir -p "$OUTPUT_DATA_DIR"
fi


: "${DEFAULT_DATASET:=${INPUT_DATA_DIR}/malaysia-singapore-brunei-latest.osm.pbf}"

INPUT_DATASET=${INPUT_DATA_DIR}/${OSM_PBF_FILE}
INPUT_FILE="${INPUT_DATASET:-${DEFAULT_DATASET}}"
SEA_FILE=${INPUT_DATA_DIR}/${OSM_SEA_FILE}
OUTPUT_FILE="${OUTPUT_DATA_DIR}/clipped.pbf"
MERGED_FILE="${OUTPUT_DATA_DIR}/merge.pbf"
MERGED_FILE_OSM="${OUTPUT_DATA_DIR}/merge.osm"
MAPFORGE_FILE="${OUTPUT_DATA_DIR}/sarawak_mapforge.map"
POI_FILE="${OUTPUT_DATA_DIR}/sarawak_poi_mapforge.poi"


function checkosm() {
    if [ ! -f "$DEFAULT_DATASET" ]; then
        echo "Downloading OSM file..."
        echo "Download from https://download.geofabrik.de/asia/malaysia-singapore-brunei-latest.osm.pbf"
        echo "Data save into ${DEFAULT_DATASET}"
        wget -O "$DEFAULT_DATASET" "https://download.geofabrik.de/asia/malaysia-singapore-brunei-latest.osm.pbf"
    else
        echo "OSM file already exists."
    fi
}

# Function to clip OSM data
# this function to clip into bounding box (sarawak)
function clip_osm() {
    echo "-------------------------------------------------------------------------------"
    echo "                                 CLIP OSM                                      "
    echo "-------------------------------------------------------------------------------"
    echo ""
    if [ ! -f "$INPUT_FILE" ]; then
        checkosm

        # clip
        echo "Clipping"
        osmosis --rb file=$INPUT_FILE --bounding-box bottom=0 left=109 top=5 right=116 --wb file=$OUTPUT_FILE
    else
        # clip
        echo "Clipping"
        osmosis --rb file=$INPUT_FILE --bounding-box bottom=0 left=109 top=5 right=116 --wb file=$OUTPUT_FILE
    fi

    # Print a message
    echo "OSM data clipped successfully."
}

function clean() {
    rm /data/output/*
}

# Function to merge clipped data back with the original input
function merge_osm() {
    echo "-------------------------------------------------------------------------------"
    echo "                                 MERGE OSM                                     "
    echo "-------------------------------------------------------------------------------"
    echo ""
    if [ ! -f "$INPUT_FILE" ]; then
        checkosm
        # clip
        echo "Clipping"
        if [ ! -f "$OUTPUT_FILE" ]; then
            osmosis --rb file=$INPUT_FILE --bounding-box bottom=0 left=109 top=5 right=116 --wb file=$OUTPUT_FILE
        fi

        if [ ! -f "$SEA_FILE" ]; then
            echo "Warning: Please provide a sea layer, otherwise nothing will be merge" >&2
            exit 1
        else
            # merge sea layer into 
            echo "Adding sea layer into clipped layer"
            osmosis --rb file=$OUTPUT_FILE --rx file=$SEA_FILE --s --m --wb file=$MERGED_FILE
            # save *.osm file too for editing in josm
            osmosis --rb file=$OUTPUT_FILE --rx file=$SEA_FILE --s --m --wx file=$MERGED_FILE_OSM
        fi
    else
        # clip
        echo "Clipping"
        if [ ! -f "$OUTPUT_FILE" ]; then
            osmosis --rb file=$INPUT_FILE --bounding-box bottom=0 left=109 top=5 right=116 --wb file=$OUTPUT_FILE
        fi

        if [ ! -f "$SEA_FILE" ]; then
            echo "Warning: Please provide a sea layer, otherwise nothing will be merge" >&2
            exit 1
        else
            # merge sea layer into 
            echo "Adding sea layer into clipped layer"
            osmosis --rb file=$OUTPUT_FILE --rx file=$SEA_FILE --s --m --wb file=$MERGED_FILE
            # save *.osm file too for editing in josm
            osmosis --rb file=$OUTPUT_FILE --rx file=$SEA_FILE --s --m --wx file=$MERGED_FILE_OSM
        fi
    fi

    # Print a message
    echo "Adding sea layer into clipped layer is successful."
    exit
}

# Function to create mapforge mapfile
function create_mapfile() {
    echo "-------------------------------------------------------------------------------"
    echo "                               CREATE MAPFILE                                  "
    echo "-------------------------------------------------------------------------------"
    echo ""
    if [ ! -f "$INPUT_FILE" ]; then
        checkosm

        # clip
        echo "Clipping"
        if [ ! -f "$OUTPUT_FILE" ]; then
            osmosis --rb file=$INPUT_FILE --bounding-box bottom=0 left=109 top=5 right=116 --wb file=$OUTPUT_FILE
        fi

        if [ ! -f "$SEA_FILE" ]; then
            echo "Convert OSM map into Mapforge map format"
            osmosis --rb file=$OUTPUT_FILE --mw file=$MAPFORGE_FILE bbox=0,109,5,116 threads=4 type=hd
            echo "Convert OSM map into Mapforge POI"
            osmosis --rb file=$OUTPUT_FILE --poi-writer file=$POI_FILE
        else
            # merge sea layer into 
            echo "Adding sea layer into clipped layer"
            if [ ! -f "$MERGED_FILE" ]; then
                osmosis --rb file=$OUTPUT_FILE --rx file=$SEA_FILE --s --m --wb file=$MERGED_FILE
            fi
            echo "Convert OSM map into Mapforge map format"
            osmosis --rb file=$MERGED_FILE --mw file=$MAPFORGE_FILE bbox=0,109,5,116 threads=4 type=hd
            echo "Convert OSM map into Mapforge POI"
            osmosis --rb file=$MERGED_FILE --poi-writer file=$POI_FILE
        fi
    else
        # clip
        echo "Clipping"
        if [ ! -f "$OUTPUT_FILE" ]; then
            osmosis --rb file=$INPUT_FILE --bounding-box bottom=0 left=109 top=5 right=116 --wb file=$OUTPUT_FILE
        fi

        if [ ! -f "$SEA_FILE" ]; then
            echo "Convert OSM map into Mapforge map format"
            osmosis --rb file=$OUTPUT_FILE --mw file=$MAPFORGE_FILE bbox=0,109,5,116 threads=4 type=hd
            echo "Convert OSM map into Mapforge POI"
            osmosis --rb file=$OUTPUT_FILE --poi-writer file=$POI_FILE
        else
            # merge sea layer into 
            echo "Adding sea layer into clipped layer"
            if [ ! -f "$MERGED_FILE" ]; then
                osmosis --rb file=$OUTPUT_FILE --rx file=$SEA_FILE --s --m --wb file=$MERGED_FILE
            fi
            echo "Convert OSM map into Mapforge map format"
            osmosis --rb file=$MERGED_FILE --mw file=$MAPFORGE_FILE bbox=0,109,5,116 threads=4 type=hd
            echo "Convert OSM map into Mapforge POI"
            osmosis --rb file=$MERGED_FILE --poi-writer file=$POI_FILE
        fi
    fi

    echo "Mapforge map and poi successfully generated"
}

function update_osm() {
    echo "-------------------------------------------------------------------------------"
    echo "                                  UPDATE OSM                                   "
    echo "-------------------------------------------------------------------------------"
    echo ""
    # Derive a change set between two files. 
    # The first file is the file after changing, the second file is the file before changing.
    OSM_ORI="${OUTPUT_DATA_DIR}/original.osm"
    CHANGED_FILE="${OUTPUT_DATA_DIR}/sarawak_changed.osc"

    if [ ! -f "${OSM_ORI}" ]; then
        osmosis --rb file="${INPUT_FILE}" --bounding-box bottom=0 left=109 top=5 right=116 --wx file="${OSM_ORI}"
    fi

    osmosis --read-xml file="${MERGED_FILE_OSM}" \
        --read-xml file="${OSM_ORI}" \
        --derive-change \
        --write-xml-change file="${CHANGED_FILE}"

    # applied changes into older version
    osmosis  --read-xml-change \
        file="${CHANGED_FILE}" \
        --read-xml file=${MERGED_FILE_OSM} \
        --apply-change \
        --write-xml file=${OSM_ORI}

    echo "Updating original completed successfully."

    exit 1
}

# Parse command-line arguments
while getopts "a:" opt; do
    case $opt in
        a)
            ACTION="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Check if action is provided
if [ -z "$ACTION" ]; then
    echo "Error: Please provide an action using the -a option (clip or merge)." >&2
    exit 1
fi

# Perform the specified action
case $ACTION in
    clip)
        clip_osm
        ;;
    merge)
        merge_osm
        ;;
    map)
        create_mapfile
        ;;
    update)
        update_osm
        ;;
    *)
        echo "Error: Invalid action. Use 'clip', 'merge' or 'map'." >&2
        exit 1
        ;;
esac

exit 0