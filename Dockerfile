FROM eclipse-temurin:17.0.7_7-jdk
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ="Asia/Kuching"
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Set the Osmosis version and download URL as build arguments
ARG OSMOSIS_VERSION='0.49.2'
ENV OSMOSIS_VERSION $OSMOSIS_VERSION

# Set the working directory
WORKDIR /opt/osmosis

# Install additional packages using apt
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        figlet \
        neofetch \
        osmium-tool \
        tzdata \
        locales \
    && echo $TZ > /etc/timezone \
    && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && sed -i "s/# $LANG UTF-8/$LANG UTF-8/" /etc/locale.gen \
    && locale-gen $LANG && update-locale LANG=$LANG \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Osmosis using curl
RUN set -x \
    && curl -SL https://github.com/openstreetmap/osmosis/releases/download/${OSMOSIS_VERSION}/osmosis-${OSMOSIS_VERSION}.tar -o /opt/osmosis.tar \
    && tar -xvf /opt/osmosis.tar -C /opt/osmosis --strip-components=1 \
    && rm /opt/osmosis.tar \
    && chmod 0755 /opt/osmosis/bin/osmosis \
    && ln -s /opt/osmosis/bin/osmosis /usr/local/bin/osmosis

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN mkdir -p /data/ && mkdir -p /opt/osm

# Set the working directory for the application
WORKDIR /opt/osm

RUN set -x \
    && mkdir -p /opt/osm/plugins/ \
    && curl -SL https://repo1.maven.org/maven2/org/mapsforge/mapsforge-map-writer/0.20.0/mapsforge-map-writer-0.20.0-jar-with-dependencies.jar \
        -o ./plugins/mapsforge-map-writer-0.20.0-jar-with-dependencies.jar \
    && curl -SL https://repo1.maven.org/maven2/org/mapsforge/mapsforge-poi-writer/0.20.0/mapsforge-poi-writer-0.20.0-jar-with-dependencies.jar \
        -o ./plugins/mapsforge-poi-writer-0.20.0-jar-with-dependencies.jar

COPY ./scripts/entrypoint.sh .


ENTRYPOINT ["/tini", "--"]

# Define the default command to run when the container starts
CMD ["./entrypoint.sh", "-a"]
