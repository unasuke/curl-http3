FROM ubuntu:20.04 as base-fetch
RUN apt-get update && apt-get install -y git

FROM ubuntu:20.04 as base-build
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y build-essential pkg-config autoconf libtool tzdata

FROM base-fetch as fetch-openssl
WORKDIR /root
RUN git clone --depth 1 -b OpenSSL_1_1_1g-quic-draft-29 https://github.com/tatsuhiro-t/openssl

FROM base-build as build-openssl
COPY --from=fetch-openssl /root/openssl /root/openssl
WORKDIR /root/openssl
RUN ./config enable-tls1_3 --prefix=/openssl
RUN make
RUN make -j`nproc`
RUN make install_sw

FROM base-fetch as fetch-nghttp3
WORKDIR /root
RUN git clone https://github.com/ngtcp2/nghttp3

FROM base-build as build-nghttp3
WORKDIR /root
COPY --from=fetch-nghttp3 /root/nghttp3 /root/nghttp3
WORKDIR /root/nghttp3
RUN autoreconf -i
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
RUN autoreconf -i
COPY --from=build-openssl /openssl/ /openssl
COPY --from=build-nghttp3 /nghttp3 /nghttp3
RUN apt-get update && apt-get install -y libev-dev
RUN ./configure PKG_CONFIG_PATH=/openssl/lib/pkgconfig:/nghttp3/lib/pkgconfig \
        LDFLAGS="-Wl,-rpath,/openssl/lib" \
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
RUN ./buildconf
COPY --from=build-openssl /openssl /openssl
COPY --from=build-nghttp3 /nghttp3 /nghttp3
COPY --from=build-ngtcp2 /ngtcp2 /ngtcp2
RUN LDFLAGS="-Wl,-rpath,/openssl/lib" \
        ./configure --with-ssl=/openssl \
        --with-nghttp3=/nghttp3 \
        --with-ngtcp2=/ngtcp2
RUN make -j`nproc`
RUN make install

FROM ubuntu:20.04 as executor
COPY --from=build-curl /etc/ld.so.conf.d/libc.conf /etc/ld.so.conf.d/libcurl.conf
COPY --from=build-curl /usr/local/lib/libcurl.so.4 /usr/local/lib/libcurl.so.4
COPY --from=build-curl /usr/local/bin/curl /usr/local/bin/curl
COPY --from=build-curl /openssl/lib/ /openssl/lib/
COPY --from=build-curl /nghttp3/lib/libnghttp3.so.0 /nghttp3/lib/libnghttp3.so.0
COPY --from=build-curl /ngtcp2/lib/libngtcp2.so.0 /ngtcp2/lib/libngtcp2.so.0
COPY --from=build-curl /ngtcp2/lib/libngtcp2_crypto_openssl.so.0 /ngtcp2/lib/libngtcp2_crypto_openssl.so.0
RUN ldconfig
CMD ["bash"]
