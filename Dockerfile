# Build container
FROM openjdk:alpine AS builder

# Configuration
ARG URL=https://media.forgecdn.net/files/2787/18/SkyFactory_4_Server_4.1.0.zip

RUN apk add --no-cache wget unzip && \
    # Download the pack
    wget -qO data.zip $URL && \
    unzip data.zip && \
    rm data.zip && \
    mv SkyFactory_4_Server_* /minecraft && \
    cd /minecraft && \
    # Accept EULA
    echo "# EULA accepted on $(date)" > eula.txt && \
    echo "eula=TRUE" >> eula.txt && \
    # Install the server
    source ./settings.sh && \
    java -jar $INSTALL_JAR --installServer && \
    # Update settings file
    sed -i '/_JAR/!d' settings.sh && \
    # Remove useless files
    rm ServerStart.* Install.* settings.bat *.pdf UPDATE.txt README.txt forge-*-installer.jar.log


# Result container
FROM openjdk:alpine
MAINTAINER Philippe Schommers <philippe@schommers.be>
WORKDIR /minecraft

# Customisable environment variables
ENV MIN_RAM="1024M" \
    MAX_RAM="4096M" \
    JAVA_PARAMETERS="-XX:+UseG1GC -Dsun.rmi.dgc.server.gcInterval=2147483646 -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M -Dfml.readTimeout=180"

# Copy the data from the build container
COPY --from=builder /minecraft .

# Create normal user
ARG USER_UID="567"
ARG USER_GID="567"

RUN addgroup -S -g $USER_GID minecraft && \
    adduser -S -u $USER_UID -G minecraft minecraft && \
    chown -R minecraft: .

# General
USER minecraft
EXPOSE 25565

# Startup script
CMD source ./settings.sh && java -server -Xms${MIN_RAM} -Xmx${MAX_RAM} ${JAVA_PARAMETERS} -jar ${SERVER_JAR} nogui
