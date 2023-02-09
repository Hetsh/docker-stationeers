FROM hetsh/steamcmd:20230208-1

# App user
ARG APP_USER="rocket"
ARG APP_UID=1358
ARG DATA_DIR="/stationeers"
RUN useradd --uid "$APP_UID" --user-group --create-home --home "$DATA_DIR" --shell /sbin/nologin "$APP_USER"

# Application
ARG APP_ID=600760
ARG DEPOT_ID=600762
ARG MANIFEST_ID=7200594610247125863
ARG APP_DIR="$STEAM_DIR/linux32/steamapps/content/app_$APP_ID/depot_$DEPOT_ID"
RUN steamcmd.sh \
        +login anonymous \
        +download_depot "$APP_ID" "$DEPOT_ID" "$MANIFEST_ID" \
        +quit && \
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
RUN ln -sf "$DATA_DIR" "$APP_DIR/saves"

#      GAME
EXPOSE 27016/udp

# Launch parameters
USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENV PATH="$APP_DIR:$PATH"
ENTRYPOINT ["rocketstation_DedicatedServer.x86_64"]
