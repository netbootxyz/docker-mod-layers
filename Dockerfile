FROM archlinux

COPY root/ /

RUN \
 echo "**** install deps ****" && \
 pacman -Sy --noconfirm \
	archiso \
	mkinitcpio-archiso \
	patch \
	rsync && \
 echo "**** patch archiso ****" && \
 patch /usr/lib/initcpio/hooks/archiso_pxe_http < /patch && \
 chmod 755 /usr/lib/initcpio/hooks/archiso_pxe_http && \
 echo "**** organize files ****" && \
 mkdir -p \
	/buildout \
	/modlayer/hooks && \
 cp \
	/usr/lib/initcpio/hooks/archiso_pxe_http \
	/modlayer/hooks/
