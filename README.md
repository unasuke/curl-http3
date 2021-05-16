# curl with HTTP/3
[![.github/workflows/build.yml](https://github.com/unasuke/curl-http3/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/unasuke/curl-http3/actions/workflows/build.yml)

## How to use

```shell
$ docker pull ghcr.io/unasuke/curl-http3:quiche-latest
$ docker run -it --rm ghcr.io/unasuke/curl-http3:quiche-latest bash
root@bdd5d7b0c697:/# curl --http3 -v https://quic.tech:8443/
*   Trying 45.77.96.66:8443...
* Connect socket 5 over QUIC to 45.77.96.66:8443
* Sent QUIC client Initial, ALPN: h3-29,h3-28,h3-27
* Connected to quic.tech () port 8443 (#0)
* h3 [:method: GET]
* h3 [:path: /]
* h3 [:scheme: https]
* h3 [:authority: quic.tech:8443]
* h3 [user-agent: curl/7.77.0-DEV]
* h3 [accept: */*]
* Using HTTP/3 Stream ID: 0 (easy handle 0x564a6b1b31d0)
> GET / HTTP/3
> Host: quic.tech:8443
> user-agent: curl/7.77.0-DEV
> accept: */*
>
< HTTP/3 200
< server: quiche
< content-length: 462
<
<!DOCTYPE html>

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">

    <link rel="shortcut icon" href="/quic.ico" type="image/x-icon">

    <style>
    img {
        position: absolute;
        margin: auto;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
    }
    </style>

    <title>quic.tech</title>
</head>

<body>
    <div class="cont">
        <img src="/quic.svg" />
    </div>
</body>
</html>
* Connection #0 to host quic.tech left intact
```
