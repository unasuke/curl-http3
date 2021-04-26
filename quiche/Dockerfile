FROM debian:bullseye

RUN apt update && apt install -y git cargo cmake build-essential autoconf libtool pkg-config

RUN git clone --recursive https://github.com/cloudflare/quiche \
  && git clone https://github.com/curl/curl

RUN cd quiche && git checkout 0.7.0 && cargo build --release --features ffi,pkg-config-meta,qlog \
  && mkdir deps/boringssl/src/lib \
  && ln -vnf $(find target/release -name libcrypto.a -o -name libssl.a) deps/boringssl/src/lib/
RUN cd curl && ./buildconf \
  && ./configure LDFLAGS="-Wl,-rpath,$PWD/../quiche/target/release" --with-ssl=$PWD/../quiche/deps/boringssl/src --with-quiche=$PWD/../quiche/target/release \
  && make \
  && make install
RUN ldconfig
