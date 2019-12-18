# static curl build
FROM alpine:3.10 as curlstage
ARG VERSION="7.67.0"

RUN \
 echo "**** install deps ****" && \
 apk add --no-cache \
	ca-certificates \
	gcc \
	make \
	musl-dev \
	openssl-dev \
	zlib-dev && \
 echo "**** download and compile curl ****" && \
 wget "https://curl.haxx.se/download/curl-${VERSION}.tar.gz" &&\
 tar -xf curl-${VERSION}.tar.gz && \
 cd curl-* && \
 ./configure \
	--disable-shared \
	--with-ca-fallback && \
 make curl_LDFLAGS=-all-static && \
 strip src/curl && \
 echo "**** organize files ****" && \
 mkdir -p \
	/curlout/bin \
	/curlout/etc/ssl/certs && \
 cp \
	src/curl \
	/curlout/bin && \
 cp \
	/etc/ssl/cert.pem \
        /curlout/etc/ssl/certs/ca-certificates.crt

# final mod layer
FROM ubuntu:bionic

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

# add files
COPY /root /
COPY --from=curlstage /curlout /curlout

RUN \
 echo "**** install deps ****" && \
 apt-get update && \
 apt-get install -y \
	casper \
	patch \
	rsync && \
 echo "**** patch casper ****" && \
 patch /usr/share/initramfs-tools/scripts/casper < /patch && \
 echo "**** organize files ****" && \
 mkdir -p \
	/buildout \
	/modlayer/scripts && \
 cp \
	/usr/share/initramfs-tools/scripts/casper \
	/modlayer/scripts/ && \
 cp -ax \
	/curlout/* \
	/modlayer/

