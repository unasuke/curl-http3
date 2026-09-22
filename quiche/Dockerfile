FROM ubuntu:26.04 AS base-fetch
RUN apt-get update && apt-get install -y git

FROM ubuntu:26.04 AS base-build
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y build-essential pkg-config tzdata

FROM base-fetch AS fetch-quiche
WORKDIR /root
RUN git clone --recursive --depth 1 --shallow-submodules https://github.com/cloudflare/quiche

FROM base-build AS build-quiche
WORKDIR /root
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y curl cmake git libclang-dev libfontconfig-dev tzdata \
  && curl https://sh.rustup.rs -sSf | sh -s -- -y
COPY --from=fetch-quiche /root/quiche /root/quiche
WORKDIR /root/quiche/
RUN ~/.cargo/bin/cargo build --package quiche --release --features ffi,pkg-config-meta,qlog \
  && ln -s libquiche.so target/release/libquiche.so.0 \
  && mkdir -p boringssl/lib \
  && find target/release \( -name libcrypto.a -o -name libssl.a \) -exec ln -vnf -- '{}' boringssl/lib \; \
  && find target/release/build/boring-sys-*/out/boringssl -maxdepth 1 -name include -exec ln -vsf -- '../{}' boringssl \;

FROM base-fetch AS fetch-curl
WORKDIR /root
RUN git clone --depth 1 https://github.com/curl/curl

FROM base-build AS build-curl
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y autoconf libtool libpsl-dev
COPY --from=fetch-curl /root/curl /root/curl
WORKDIR /root/curl
RUN autoreconf -fi
COPY --from=build-quiche /root/quiche /root/quiche
RUN ./configure LDFLAGS="-Wl,-rpath,$PWD/../quiche/target/release" LIBS="-lstdc++" \
  --with-openssl=$PWD/../quiche/boringssl \
  --with-quiche=$PWD/../quiche/target/release \
  --with-ca-path=/etc/ssl/certs
RUN make -j`nproc`
RUN make install

FROM ubuntu:26.04 AS executor
RUN apt update && apt install -y --no-install-recommends ca-certificates libpsl5 && rm -rf /var/lib/apt/lists/*
COPY --from=build-curl /etc/ld.so.conf.d/libc.conf /etc/ld.so.conf.d/libcurl.conf
COPY --from=build-curl /usr/local/lib/libcurl.so.4 /usr/local/lib/libcurl.so.4
COPY --from=build-curl /etc/ld.so.conf.d/libc.conf /etc/ld.so.conf.d/libquiche.conf
COPY --from=build-curl /root/quiche/target/release/libquiche.so /usr/local/lib/libquiche.so
COPY --from=build-curl /usr/local/bin/curl /usr/local/bin/curl
RUN ldconfig
CMD ["bash"]
