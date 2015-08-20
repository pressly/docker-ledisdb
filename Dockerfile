FROM golang:1.5
MAINTAINER Peter Kieltyka <peter@pressly.com>

RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates curl git-core mercurial \
    g++ dh-autoreconf pkg-config libgflags-dev

# Install Rocksdb
RUN cd /tmp && git clone https://github.com/facebook/rocksdb.git && \
  cd rocksdb && \
  git checkout v3.12.1 && \
  make shared_lib && \
  mkdir -p /usr/local/rocksdb/lib && \
  mkdir /usr/local/rocksdb/include && \
  cp librocksdb.so* /usr/local/rocksdb/lib && \
  cp /usr/local/rocksdb/lib/librocksdb.so* /usr/lib/ && \
  cp -r include /usr/local/rocksdb/

# Install Ledisdb
RUN go get github.com/tools/godep

RUN \
  mkdir -p $GOPATH/src/github.com/siddontang/ledisdb && \
  cd $GOPATH/src/github.com/siddontang && \
  git clone https://github.com/siddontang/ledisdb.git && \
  cd ledisdb && bash dev.sh && make

EXPOSE 6380

CMD $GOPATH/bin/ledis-server -config=/etc/ledisdb.conf
