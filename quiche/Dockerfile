FROM ubuntu:20.04 as base-fetch
RUN apt-get update && apt-get install -y git

FROM ubuntu:20.04 as base-build
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y build-essential pkg-config tzdata

FROM base-fetch as fetch-quiche
WORKDIR /root
RUN git clone --recursive --depth 1 -b 0.9.0 https://github.com/cloudflare/quiche

FROM base-build as build-quiche
WORKDIR /root
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y curl cmake tzdata \
  && curl https://sh.rustup.rs -sSf | sh -s -- -y
COPY --from=fetch-quiche /root/quiche /root/quiche
WORKDIR /root/quiche/
RUN ~/.cargo/bin/cargo build --release --features ffi,pkg-config-meta,qlog \
  && mkdir deps/boringssl/src/lib \
  && ln -vnf $(find target/release -name libcrypto.a -o -name libssl.a) deps/boringssl/src/lib/

FROM base-fetch as fetch-curl
WORKDIR /root
RUN git clone --depth 1 https://github.com/curl/curl

FROM base-build as build-curl
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y autoconf libtool
COPY --from=fetch-curl /root/curl /root/curl
WORKDIR /root/curl
RUN ./buildconf
COPY --from=build-quiche /root/quiche /root/quiche
RUN ./configure LDFLAGS="-Wl,-rpath,$PWD/../quiche/target/release" \
        --with-openssl=$PWD/../quiche/deps/boringssl/src \
        --with-quiche=$PWD/../quiche/target/release
RUN make -j`nproc`
RUN make install

FROM ubuntu:20.04 as executor
COPY --from=build-curl /etc/ld.so.conf.d/libc.conf /etc/ld.so.conf.d/libcurl.conf
COPY --from=build-curl /usr/local/lib/libcurl.so.4 /usr/local/lib/libcurl.so.4
COPY --from=build-curl /etc/ld.so.conf.d/libc.conf /etc/ld.so.conf.d/libquiche.conf
COPY --from=build-curl /root/quiche/target/release/libquiche.so /usr/local/lib/libquiche.so
COPY --from=build-curl /usr/local/bin/curl /usr/local/bin/curl
RUN ldconfig
CMD ["bash"]
