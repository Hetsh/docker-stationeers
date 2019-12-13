# Stationeers
Simple Stationeers server.

## Running the server
```bash
docker run --detach --name stationeers --publish 27500:27500/udp 27015:27015/udp hetsh/stationeers
```

## Stopping the container
```bash
docker stop stationeers
```

## Creating persistent storage
```bash
MP="/path/to/storage"
mkdir -p "$MP"
chown -R 1358:1358 "$MP"
```
`1358` is the numerical id of the user running the server (see Dockerfile).
Start the server with the additional mount flag:
```bash
docker run --mount type=bind,source=/path/to/storage,target=/stationeers ...
```

## Automate startup and shutdown via systemd
```bash
systemctl enable stationeers@<port> --now
```
The systemd unit can be found in my [GitHub](https://github.com/Hetsh/docker-stationeers) repository. Individual server instances are distinguished by host-port. By default, the systemd service assumes `/srv/stationeers_<port>` for persistent storage.

## Fork Me!
This is an open project (visit [GitHub](https://github.com/Hetsh/docker-stationeers)). Please feel free to ask questions, file an issue or contribute to it.