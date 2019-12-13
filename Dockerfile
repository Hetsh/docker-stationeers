FROM hetsh/steamcmd:1.0

ARG RS_DIR="/stationeers"
ARG RS_USER="rocket"
RUN useradd -r -m -d "$RS_DIR" -u 1358 "$RS_USER"

ARG RS_APP_ID="600760"
ARG RS_DEPOT_ID="600762"
ARG RS_MANIFEST_ID="3766921144342894408"
RUN "./steamcmd.sh" +login anonymous +download_depot "$RS_APP_ID" "$RS_DEPOT_ID" "$RS_MANIFEST_ID" +quit && \
    chown -R "$RS_USER":"$RS_USER" .

WORKDIR "$RS_DIR"
RUN chown "$RS_USER":"$RS_USER" .
USER "$RS_USER"
VOLUME ["$RS_DIR"]
EXPOSE 27500/udp 27500/tcp 27015/udp
#      GAME      RCON      QUERY

ENV RS_SAVE_INTERVAL="300"
ENV RS_WORLD_TYPE="Mars"
ENV RS_SERVER_NAME="RS_Docker"
ENV RS_DIR="$RS_DIR"
ENV RS_BIN="/steam/linux32/steamapps/content/app_$RS_APP_ID/depot_$RS_DEPOT_ID/rocketstation_DedicatedServer.x86_64"
ENTRYPOINT exec "$RS_BIN" -batchmode -nographics -autostart \
    -basedirectory="$RS_DIR" \
    -autosaveinterval="$RS_SAVE_INTERVAL" \
    -worldtype="$RS_WORLD_TYPE" \
    -worldname="$RS_WORLD_TYPE" \
    -servername="$RS_SERVER_NAME"
