FROM ubuntu:22.04 as base-fetch
RUN apt-get update && apt-get install -y git

FROM ubuntu:22.04 as base-build
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y build-essential pkg-config tzdata cmake

FROM base-fetch as fetch-msh3
WORKDIR /root
RUN git clone --recursive --depth 1 https://github.com/nibanks/msh3

FROM base-build as build-msh3
WORKDIR /root
COPY --from=fetch-msh3 /root/msh3 /root/msh3
WORKDIR /root/msh3/build
RUN cmake -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=RelWithDebInfo .. \
  && cmake --build . \
  && cmake --install .

FROM base-fetch as fetch-curl
WORKDIR /root
RUN git clone --depth 1 https://github.com/curl/curl

FROM base-build as build-curl
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y autoconf libtool libssl-dev
COPY --from=build-msh3 /usr/local /usr/local
COPY --from=fetch-curl /root/curl /root/curl
WORKDIR /root/curl
RUN autoreconf -fi
RUN ./configure LDFLAGS="-Wl,-rpath,/usr/local/lib" --with-msh3=/usr/local --with-openssl
RUN make -j`nproc`
RUN make install

FROM ubuntu:22.04 as executor
RUN apt update && apt install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build-curl /etc/ld.so.conf.d/libc.conf /etc/ld.so.conf.d/libcurl.conf
COPY --from=build-curl /usr/local/lib/libcurl.so.4 /usr/local/lib/libcurl.so.4
COPY --from=build-curl /usr/local/lib/libmsh3.so /usr/local/lib/libmsh3.so
COPY --from=build-curl /usr/local/lib/libmsquic.so /usr/local/lib/libmsquic.so
COPY --from=build-curl /usr/local/bin/curl /usr/local/bin/curl
RUN ldconfig
CMD ["bash"]
