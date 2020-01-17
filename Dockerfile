FROM archlinux/base

COPY root/ /

RUN \
 echo "**** install deps ****" && \
 pacman -Sy --noconfirm \
	archiso \
	patch \
	rsync && \
 echo "**** patch casper ****" && \
 patch /usr/lib/initcpio/hooks/archiso_pxe_http < /patch && \
 echo "**** organize files ****" && \
 mkdir -p \
	/buildout \
	/modlayer/hooks && \
 cp \
	/usr/lib/initcpio/hooks/archiso_pxe_http \
	/modlayer/hooks/
