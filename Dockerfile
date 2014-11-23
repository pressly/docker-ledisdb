# Ledisdb with Rocksdb and Leveldb
FROM ubuntu:14.04
MAINTAINER Peter Kieltyka <peter@pressly.com>

RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates curl git-core mercurial \
    g++ dh-autoreconf pkg-config libgflags-dev

# Install Snappy lib 1.1.2
ENV SNAPPY_DIR /usr/local/snappy
RUN cd /tmp && git clone https://github.com/siddontang/snappy.git && \
  cd ./snappy && \
  autoreconf --force --install && \
  ./configure --prefix=$SNAPPY_DIR && \
  make && make install

# Install Rocksdb 3.8
RUN cd /tmp && git clone https://github.com/facebook/rocksdb.git && \
  cd rocksdb && \
  git checkout -b 3.8.fb origin/3.8.fb && \
  make shared_lib && \
  mkdir -p /usr/local/rocksdb/lib && \
  mkdir /usr/local/rocksdb/include && \
  cp librocksdb.so /usr/local/rocksdb/lib && \
  cp -r include /usr/local/rocksdb/ && \
  ln -s /usr/local/rocksdb/lib/librocksdb.so /usr/lib/librocksdb.so

# Install Leveldb 1.18
ENV LEVELDB_DIR /usr/local/leveldb
RUN cd /tmp && git clone https://github.com/siddontang/leveldb.git && \
  cd ./leveldb && \
  echo "echo \"PLATFORM_CFLAGS+=-I$SNAPPY_DIR/include\" >> build_config.mk" >> build_detect_platform && \
  echo "echo \"PLATFORM_CXXFLAGS+=-I$SNAPPY_DIR/include\" >> build_config.mk" >> build_detect_platform && \
  echo "echo \"PLATFORM_LDFLAGS+=-L $SNAPPY_DIR/lib -lsnappy\" >> build_config.mk" >> build_detect_platform && \
  make SNAPPY=1 && \
  mkdir -p $LEVELDB_DIR/include/leveldb && \
  install include/leveldb/*.h $LEVELDB_DIR/include/leveldb && \
  mkdir -p $LEVELDB_DIR/lib && \
  cp -P libleveldb.* $LEVELDB_DIR/lib && \
  ln -s /usr/local/leveldb/lib/libleveldb.so.1 /usr/lib/libleveldb.so.1


# Install Go 1.3.3
RUN curl -s https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz | tar -v -C /usr/local -xz
ENV GOPATH /go
ENV GOROOT /usr/local/go
ENV PATH /usr/local/go/bin:/go/bin:/usr/local/bin:$PATH

# Install Godep tool
RUN go get github.com/tools/godep

# Install Ledisdb
RUN \
  mkdir -p $GOPATH/src/github.com/siddontang/ledisdb && \
  cd $GOPATH/src/github.com/siddontang && \
  git clone https://github.com/siddontang/ledisdb.git && \
  cd ledisdb && git checkout tags/v0.4 && \
  godep restore && make

EXPOSE 6380

CMD $GOPATH/bin/ledis-server -config=/etc/ledisdb.conf
