#!/usr/bin/env bash

set -eux

docker pull ghcr.io/unasuke/curl-http3:ngtcp2-latest

docker run --rm ghcr.io/unasuke/curl-http3:ngtcp2-latest /usr/local/bin/curl --http3 https://www.google.com/
docker run --rm ghcr.io/unasuke/curl-http3:ngtcp2-latest /usr/local/bin/curl --http3 https://nghttp2.org:4433/
