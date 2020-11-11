FROM hetsh/steamcmd:1.1-16

# App user
ARG APP_USER="rocket"
ARG APP_UID=1358
ARG DATA_DIR="/stationeers"
RUN useradd --uid "$APP_UID" --user-group --create-home --home "$DATA_DIR" --shell /sbin/nologin "$APP_USER"

# Application
ARG APP_ID=600760
ARG DEPOT_ID=600762
ARG MANIFEST_ID=7908117257202780562
ARG APP_DIR="$STEAM_DIR/linux32/steamapps/content/app_$APP_ID/depot_$DEPOT_ID"
RUN steamcmd.sh +login anonymous +download_depot "$APP_ID" "$DEPOT_ID" "$MANIFEST_ID" +quit && \
    find "$APP_DIR" -type d -name ".svn" -depth -exec rm -r {} \; && \
    chown -R "$APP_USER":"$APP_USER" "$STEAM_DIR" && \
    rm -r /tmp/dumps

# Volume
ARG LOG_DIR="/var/log/stationeers"
RUN mkdir -p "$LOG_DIR" && \
    chown -R "$APP_USER":"$APP_USER" "$LOG_DIR"
VOLUME ["$DATA_DIR", "$LOG_DIR"]

#      GAME      RCON      QUERY
EXPOSE 27500/udp 27500/tcp 27015/udp

# Launch parameters
USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENV APP_DIR="$APP_DIR"
ENV LOG_DIR="$LOG_DIR"
ENV DATA_DIR="$DATA_DIR"
ENV SAVE_INTERVAL="300"
ENV CLEAR_INTERVAL="60"
ENV WORLD_TYPE="Moon"
ENV WORLD_NAME="Base"
ENV SERVER_OPTS=""
ENTRYPOINT exec "$APP_DIR/rocketstation_DedicatedServer.x86_64" \
    -batchmode \
    -nographics \
    -autostart \
    -basedirectory="$DATA_DIR" \
    -logfile="$LOG_DIR/game.log" \
    -autosaveinterval="$SAVE_INTERVAL" \
    -clearallinterval="$CLEAR_INTERVAL" \
    -worldtype="$WORLD_TYPE" \
    -worldname="$WORLD_NAME" \
    -loadworld="$WORLD_NAME" \
    $SERVER_OPTS
