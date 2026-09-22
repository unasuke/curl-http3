# curl with HTTP/3
[![quiche](https://github.com/unasuke/curl-http3/actions/workflows/quiche.yml/badge.svg)](https://github.com/unasuke/curl-http3/actions/workflows/quiche.yml)
[![ngtcp2](https://github.com/unasuke/curl-http3/actions/workflows/ngtcp2.yml/badge.svg)](https://github.com/unasuke/curl-http3/actions/workflows/ngtcp2.yml)

## How to use

### quiche

```shell
$ docker pull ghcr.io/unasuke/curl-http3:quiche-latest
$ docker run -it --rm ghcr.io/unasuke/curl-http3:quiche-latest bash
root@3e8097861e83:/# curl --http3 -iv https://quic.rocks:4433/ -o /dev/null
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0*   Trying 216.155.158.183:4433...
*  CAfile: none
*  CApath: /etc/ssl/certs
* Connect socket 5 over QUIC to 216.155.158.183:4433
* Sent QUIC client Initial, ALPN: h3,h3-29,h3-28,h3-27
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0*   Trying 2001:19f0:4:34::1:4433...
* Immediate connect fail for 2001:19f0:4:34::1: Cannot assign requested address
*  subjectAltName: host "quic.rocks" matched cert's "quic.rocks"
* Verified certificate just fine
* Connected to quic.rocks () port 4433 (#0)
* h2h3 [:method: GET]
* h2h3 [:path: /]
* h2h3 [:scheme: https]
* h2h3 [:authority: quic.rocks:4433]
* h2h3 [user-agent: curl/7.83.0-DEV]
* h2h3 [accept: */*]
* Using HTTP/3 Stream ID: 0 (easy handle 0x55b0f3699610)
> GET / HTTP/3
> Host: quic.rocks:4433
> user-agent: curl/7.83.0-DEV
> accept: */*
>
< HTTP/3 200
< content-type: text/html; charset=UTF-8
< x-original-url: https://quic.rocks/
< alt-svc: h3=":4433"; ma=3600, h3-29=":4433"; ma=3600
<
{ [164 bytes data]
100   164    0   164    0     0    198      0 --:--:-- --:--:-- --:--:--   198
* Connection #0 to host quic.rocks left intact
root@3e8097861e83:/#
```


### ngtcp2

```shell
$ docker pull ghcr.io/unasuke/curl-http3:ngtcp2-latest
$ docker run -it --rm ghcr.io/unasuke/curl-http3:ngtcp2-latest bash
root@2aa5bb20b427:/# curl -iv --http3 https://nghttp2.org:4433 -o /dev/null
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0*   Trying 139.162.123.134:4433...
* Connect socket 5 over QUIC to 139.162.123.134:4433
*  CAfile: none
*  CApath: /etc/ssl/certs
*  subjectAltName: host "nghttp2.org" matched cert's "nghttp2.org"
* Verified certificate just fine
* Connected to nghttp2.org () port 4433 (#0)
* h2h3 [:method: GET]
* h2h3 [:path: /]
* h2h3 [:scheme: https]
* h2h3 [:authority: nghttp2.org:4433]
* h2h3 [user-agent: curl/7.83.0-DEV]
* h2h3 [accept: */*]
* Using HTTP/3 Stream ID: 0 (easy handle 0x55f91be2f420)
> GET / HTTP/3
> Host: nghttp2.org:4433
> user-agent: curl/7.83.0-DEV
> accept: */*
>
< HTTP/3 200
< server: nghttp3/ngtcp2 server
< content-type: text/html
< content-length: 6616
<
{ [560 bytes data]
100  6616  100  6616    0     0  30665      0 --:--:-- --:--:-- --:--:-- 30772
* Connection #0 to host nghttp2.org left intact
root@2aa5bb20b427:/#
```
