# Ledisdb Dockerfile

A docker image for https://github.com/siddontang/ledisdb with Rocksdb and Leveldb

## Usage

Server:
```
$ docker run --name=ledisdb -d -p 6380:6380 -v /data/etc/ledisdb.conf:/etc/ledisdb.conf -v /data:/data pressly/ledisdb
```

Client:
```
$ docker run -it --rm --link ledisdb:ledisdb pressly/ledisdb ledis-cli -h ledisdb
```
