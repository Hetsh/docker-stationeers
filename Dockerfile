FROM hetsh/steamcmd:20210208-1

# App user
ARG APP_USER="rocket"
ARG APP_UID=1358
ARG DATA_DIR="/stationeers"
RUN useradd --uid "$APP_UID" --user-group --create-home --home "$DATA_DIR" --shell /sbin/nologin "$APP_USER"

# Application
ARG APP_ID=600760
ARG DEPOT_ID=600762
ARG MANIFEST_ID=6309198064442997138
ARG APP_DIR="$STEAM_DIR/linux32/steamapps/content/app_$APP_ID/depot_$DEPOT_ID"
RUN steamcmd.sh +login anonymous +download_depot "$APP_ID" "$DEPOT_ID" "$MANIFEST_ID" +quit && \
    find "$APP_DIR" -type d -name ".svn" -depth -exec rm -r {} \; && \
    chown -R "$APP_USER":"$APP_USER" "$STEAM_DIR" && \
    rm -r \
        "$STEAM_DIR"/package/steamcmd_bins_linux.zip* \
        "$STEAM_DIR"/package/steamcmd_linux.zip* \
        "$STEAM_DIR"/package/steamcmd_public_all.zip* \
        "$STEAM_DIR"/package/steamcmd_siteserverui_linux.zip* \
        /tmp/dumps \
        /root/.steam \
        /root/Steam

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
ENV APP_DIR="$APP_DIR" \
    LOG_DIR="$LOG_DIR" \
    DATA_DIR="$DATA_DIR" \
    SAVE_INTERVAL="300" \
    CLEAR_INTERVAL="60" \
    WORLD_TYPE="Moon" \
    WORLD_NAME="Base" \
    SERVER_OPTS=""
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
