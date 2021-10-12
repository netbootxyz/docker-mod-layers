FROM manjarolinux/base:latest

COPY root/ /

RUN \
 echo "**** install deps ****" && \
 pacman -Sy && \
 pacman -S --noconfirm \
	manjaro-tools-iso \
	rsync && \
 echo "**** patch files prep modlayer ****" && \
 patch /etc/initcpio/hooks/miso_pxe_http < /patch && \
 chmod 755 /etc/initcpio/hooks/miso_pxe_http && \
 mkdir -p \
	/buildout \
	/modlayer/hooks && \
 cp \
	/etc/initcpio/hooks/miso_pxe_http \
	/modlayer/hooks/
