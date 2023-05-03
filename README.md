# openttd-jgrpp-docker

```
docker run --rm -it -v /data/openttd:/data:rw -p 3979:3979 -p 3979:3979/udp ghcr.io/erinacio/openttd-jgrpp:${JGRPP_VERSION} -D -d net=2
```

### Changes from v0.41.2

#### Client Name Check for Servers

Server must have a non-empty "client name", use `name <server_name>` like `name host_server` to set it if server is started from scratch.

If server's client name is empty, clients will reject to join the server without any explicit indication explaining why.

#### Dedicated Server Verbose Log

JGRPP changed debug level for `net` to 4 for dedicated servers, which will generate a lot of verbose logs like:

- `dbg: [net] [tcp/game] sent packet type 24 (SERVER_FRAME) to client 5, status: 9 (ACTIVE)`
    - Printed at debug level 3, generates over 30 lines of log every second.
- `dbg: [net] [tcp/game] received packet type 25 (CLIENT_ACK) from client 5, status: 9 (ACTIVE)`
    - Printed at debug level 3, generates 1 line of log every 2 seconds.

Be sure to explicitly set debug level for `net` to 2 by indicating `-d net=2` in command line options if you don't want to be flooded with verbose logs.
