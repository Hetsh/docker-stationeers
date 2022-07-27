# Stationeers
Simple to set up stationeers server.

## Disclaimer: Refactor
The server was rewritten from scratch in June 2022 (see [blogpost](https://store.steampowered.com/news/app/544550/view/3333239887479401585)).
With the refactor came many usability changes, that have to be accounted for.
From [tag 2071934691806169918-2](https://github.com/Hetsh/docker-stationeers/releases/tag/2071934691806169918-2) onwards, the image contains changes discussed in [issue #7](https://github.com/Hetsh/docker-stationeers/issues/7).
I am depending on your feedback because I can't run any in-depth tests right now.
So if you find any issues please open a ticket over [on GitHub](https://github.com/Hetsh/docker-stationeers/issues/new).

## Running the server
```bash
docker run --detach --name stationeers --publish 27016:27016/udp hetsh/stationeers
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

## Configuration
It is currently best to stick to the official [server-guide](https://github.com/rocket2guns/StationeersDedicatedServerGuide) for now.
Add launch parameters by appending them to the end:
```bash
docker run ... hetsh/stationeers <lanch> <parameters> <here>
```

## Updates
This image contains a specific version of the game and will not update on startup, this decreases starting time and disk space usage.
Version number is the manifest id that can also be found on [SteamDB](https://steamdb.info/depot/600762).
This id and therefore the image on docker hub is updated hourly.

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-stationeers)).
Please feel free to ask questions, file an issue or contribute to it.
