# static curl build
FROM alpine:3.14 as curlstage
ARG VERSION="7.78.0"

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
        --with-openssl \
	--with-ca-fallback && \
 make curl_LDFLAGS=-all-static && \
 strip src/curl && \
 echo "**** organize files ****" && \
 mkdir -p \
	/curlout/usr/bin \
	/curlout/etc/ssl/certs && \
 cp \
	src/curl \
	/curlout/usr/bin && \
 cp \
	/etc/ssl/cert.pem \
        /curlout/etc/ssl/certs/ca-certificates.crt

# final mod layer
FROM debian:bullseye

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
        live-boot \
        patch \
	rsync && \
 echo "**** patch live-boot ****" && \
 patch /lib/live/boot/9990-mount-http.sh < /patch && \
 echo "**** organize files ****" && \
 mkdir -p \
	/buildout \
	/modlayer/usr/lib/live/boot && \
 cp -ax \
	/curlout/* \
	/modlayer/ && \
 cp \
	/lib/live/boot/9990-mount-http.sh \
	/modlayer/usr/lib/live/boot/ 
