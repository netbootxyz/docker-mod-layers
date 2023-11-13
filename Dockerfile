# static curl build
FROM alpine:3.18 as curlstage
ARG VERSION="8.4.0"

RUN \
 echo "**** install deps ****" && \
 apk add --no-cache build-base \
                    clang \
                    openssl-dev \
                    libssh2-dev \
                    libssh2-static \
                    openssl-libs-static \
                    zlib-static && \
 echo "**** download and compile curl ****" && \
 wget "https://curl.haxx.se/download/curl-${VERSION}.tar.gz" &&\
 tar -xf curl-${VERSION}.tar.gz && \
 cd curl-* && \
 export CC=clang && \
 LDFLAGS="-static" \
 PKG_CONFIG="pkg-config --static" ./configure --disable-shared \
                                              --enable-static \
                                              --disable-ldap \
                                              --enable-ipv6 \
                                              --enable-unix-sockets \
                                              --with-ssl \
                                              --with-libssh2 && \
 make -j4 V=1 LDFLAGS="-static -all-static" && \
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
 patch /usr/share/initramfs-tools/scripts/casper-bottom/24preseed < /preseed-patch && \
 echo "**** organize files ****" && \
 mkdir -p \
	/buildout \
	/modlayer/scripts/casper-bottom && \
 cp \
	/usr/share/initramfs-tools/scripts/casper \
	/modlayer/scripts/ && \
 cp \
	/usr/share/initramfs-tools/scripts/casper-bottom/24preseed \
	/modlayer/scripts/casper-bottom/24preseed && \
 cp -ax \
	/curlout/* \
	/modlayer/

