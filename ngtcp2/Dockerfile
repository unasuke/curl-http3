FROM ubuntu:22.04 as base-fetch
RUN apt-get update && apt-get install -y git

FROM ubuntu:22.04 as base-build
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y build-essential pkg-config autoconf libtool tzdata

FROM base-fetch as fetch-openssl
WORKDIR /root
RUN git clone --depth 1 -b openssl-3.0.0+quic https://github.com/quictls/openssl

FROM base-build as build-openssl
COPY --from=fetch-openssl /root/openssl /root/openssl
WORKDIR /root/openssl
RUN ./config enable-tls1_3 --prefix=/openssl
RUN make -j`nproc`
RUN make install

FROM base-fetch as fetch-nghttp3
WORKDIR /root
RUN git clone --depth 1 https://github.com/ngtcp2/nghttp3

FROM base-build as build-nghttp3
WORKDIR /root
COPY --from=fetch-nghttp3 /root/nghttp3 /root/nghttp3
WORKDIR /root/nghttp3
RUN autoreconf -fi
RUN ./configure --prefix=/nghttp3 --enable-lib-only
RUN make -j`nproc`
RUN make install

FROM base-fetch as fetch-ngtcp2
WORKDIR /root
RUN git clone https://github.com/ngtcp2/ngtcp2

FROM base-build as build-ngtcp2
WORKDIR /root
COPY --from=fetch-ngtcp2 /root/ngtcp2 /root/ngtcp2
WORKDIR /root/ngtcp2
COPY --from=build-openssl /openssl/ /openssl
COPY --from=build-nghttp3 /nghttp3 /nghttp3
RUN apt-get update && apt-get install -y libev-dev
RUN autoreconf -fi
RUN ./configure PKG_CONFIG_PATH=/openssl/lib64/pkgconfig:/nghttp3/lib/pkgconfig \
        LDFLAGS="-Wl,-rpath,/openssl/lib64" \
        --prefix=/ngtcp2 \
        --enable-lib-only
RUN make -j`nproc`
RUN make install

FROM base-fetch as fetch-curl
WORKDIR /root
RUN git clone --depth 1 https://github.com/curl/curl

FROM base-build as build-curl
RUN apt-get update && apt-get install -y libtool
COPY --from=fetch-curl /root/curl /root/curl
WORKDIR /root/curl
COPY --from=build-openssl /openssl /openssl
COPY --from=build-nghttp3 /nghttp3 /nghttp3
COPY --from=build-ngtcp2 /ngtcp2 /ngtcp2
RUN autoreconf -fi
RUN LDFLAGS="-Wl,-rpath,/openssl/lib64" \
        ./configure --with-openssl=/openssl \
        --with-nghttp3=/nghttp3 \
        --with-ngtcp2=/ngtcp2 \
        --with-ca-path=/etc/ssl/certs
RUN make -j`nproc`
RUN make install

FROM ubuntu:22.04 as executor
RUN apt update && apt install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build-curl /etc/ld.so.conf.d/libc.conf /etc/ld.so.conf.d/libcurl.conf
COPY --from=build-curl /usr/local/lib/libcurl.so.4 /usr/local/lib/libcurl.so.4
COPY --from=build-curl /usr/local/bin/curl /usr/local/bin/curl
COPY --from=build-curl /openssl/lib64/ /openssl/lib64/
COPY --from=build-curl /nghttp3/lib/libnghttp3.so.3 /nghttp3/lib/libnghttp3.so.3
COPY --from=build-curl /ngtcp2/lib/libngtcp2.so.7 /ngtcp2/lib/libngtcp2.so.7
COPY --from=build-curl /ngtcp2/lib/libngtcp2_crypto_openssl.so.2 /ngtcp2/lib/libngtcp2_crypto_openssl.so.2
RUN ldconfig
CMD ["bash"]
