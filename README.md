# Stationeers
Simple to set up stationeers server.

## Running the server
```bash
docker run --detach --name stationeers --publish 27500:27500/udp --publish 27015:27015/udp hetsh/stationeers
```

## Stopping the container
```bash
docker stop stationeers
```

## Creating persistent storage
To keep worlds, configuration and logs, you need to create a writeable directory:
```bash
MP="/path/to/storage"
mkdir -p "$MP"
chown -R 1358:1358 "$MP"
```
`1358` is the numerical id of the user running the server (see [Dockerfile](https://github.com/Hetsh/docker-stationeers/blob/master/Dockerfile)).
Start the server with the additional mount flag:
```bash
docker run --mount type=bind,source=/path/to/storage,target=/stationeers ...
```

## Configuring Maps
Maps (worlds) are configured via environment variables `WORLD_TYPE` and `WORLD_NAME` with default values `Moon` and `Base`.
To change the world, launch the server with additional parameters (Mars example) `--env WORLD_TYPE=Mars --env WORLD_NAME=MarsBase`.
If `WORLD_NAME` already exists, the save is loaded instead and `WORLD_TYPE` is ignored.

## Updates
This image contains a specific version of the game and will not update on startup, this decreases starting time and disk space usage.
Version number is the manifest id that can also be found on [SteamDB](https://steamdb.info/depot/600762).
This id and therefore the image on docker hub is updated hourly.

## Automate startup and shutdown via systemd
This [systemd unit file](https://github.com/Hetsh/docker-stationeers/blob/master/stationeers%40.service) is intended to launch containers on startup without additional software and only depends on a running docker daemon.
It fits my personal setup, so you might need to adjust some parameters to your needs.
Because this is a template unit file, you can easily change the world:
```bash
systemctl enable stationeers@<world> --now
```

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-stationeers)).
Please feel free to ask questions, file an issue or contribute to it.
