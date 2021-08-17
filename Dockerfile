FROM manjarolinux/base:latest

RUN \
 echo "**** install deps ****" && \
 pacman -Sy && \
 pacman -S --noconfirm \
	manjaro-tools-iso \
	rsync && \
 echo "**** patch files prep modlayer ****" && \
 sed -i \
	-e 's/${misobasedir}\/${arch}//g' \
	-e 's/"OK"/"OK\\|302 Found"/g' \
	/etc/initcpio/hooks/miso_pxe_http && \
 mkdir -p \
	/buildout \
	/modlayer/hooks && \
 cp \
	/etc/initcpio/hooks/miso_pxe_http \
	/modlayer/hooks/
