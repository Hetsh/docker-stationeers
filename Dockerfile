FROM hetsh/steamcmd:1.1-1

ARG APP_DIR="/stationeers"
ARG APP_USER="rocket"
RUN useradd -r -m -d "$APP_DIR" -u 1358 "$APP_USER"

ARG APP_ID=600760
ARG DEPOT_ID=600762
ARG MANIFEST_ID=3766921144342894408
RUN "./steamcmd.sh" +login anonymous +download_depot "$APP_ID" "$DEPOT_ID" "$MANIFEST_ID" +quit && \
    chown -R "$APP_USER":"$APP_USER" .

WORKDIR "$APP_DIR"
RUN chown -R "$APP_USER":"$APP_USER" .
USER "$APP_USER":"$APP_USER"
VOLUME ["$APP_DIR"]
EXPOSE 27500/udp 27500/tcp 27015/udp
#      GAME      RCON      QUERY

ENV BIN="/steam/linux32/steamapps/content/app_$APP_ID/depot_$DEPOT_ID/rocketstation_DedicatedServer.x86_64"
ENV APP_DIR="$APP_DIR"
ENV SAVE_INTERVAL="300"
ENV CLEAR_INTERVAL="60"
ENV WORLD_TYPE="Moon"
ENV WORLD_NAME="Base"
ENTRYPOINT exec "$BIN" \
    -batchmode \
    -nographics \
    -autostart \
    -basedirectory="$APP_DIR" \
    -autosaveinterval="$SAVE_INTERVAL" \
    -clearallinterval="$CLEAR_INTERVAL" \
    -worldtype="$WORLD_TYPE" \
    -worldname="$WORLD_NAME" \
    -loadworld="$WORLD_NAME"
