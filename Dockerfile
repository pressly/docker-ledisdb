FROM golang:1.7rc3
MAINTAINER Peter Kieltyka <peter@pressly.com>

RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates curl git-core mercurial \
    g++ dh-autoreconf pkg-config libgflags-dev

# Install Rocksdb
RUN cd /tmp && git clone https://github.com/facebook/rocksdb.git && \
  cd rocksdb && \
  git checkout v4.9 && \
  make shared_lib && \
  mkdir -p /usr/local/rocksdb/lib && \
  mkdir /usr/local/rocksdb/include && \
  cp librocksdb.so* /usr/local/rocksdb/lib && \
  cp /usr/local/rocksdb/lib/librocksdb.so* /usr/lib/ && \
  cp -r include /usr/local/rocksdb/

RUN \
  mkdir -p $GOPATH/src/github.com/siddontang && \
  cd $GOPATH/src/github.com/siddontang && \
  git clone https://github.com/siddontang/ledisdb.git && \
  cd ledisdb && \
  ln -s ./cmd/vendor ./vendor && bash dev.sh && make && \
  mv ./bin/ledis* $GOPATH/bin/



EXPOSE 6380

CMD $GOPATH/bin/ledis-server -config=/etc/ledisdb.conf