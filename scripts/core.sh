#!/bin/bash
# -*- mode: shell-script; coding: utf-8-emacs-unix; sh-basic-offset: 8; indent-tabs-mode: t -*-

sourceroot="$(readlink -f $(dirname $0)/../sourceroot)"

die() {
	echo -e "\033[1;30m>\033[0;31m>\033[1;31m> ERROR:\033[0m ${@}" && exit 1
}

einfo() {
	echo -ne "\033[1;30m>\033[0;36m>\033[1;36m> \033[0m${@}\n"
}
ewarn() {
	echo -ne "\033[1;30m>\033[0;33m>\033[1;33m> \033[0m${@}\n"
}

dobin() {
	source="$1"
	if [[ ! -z $2 ]]; then
		target="$sourceroot/bin/$(basename $2)"
	else
		target="$sourceroot/bin/$(basename $source)"
	fi

	addbin() {
		if ! ldd $source >> /dev/null; then
			einfo "Adding $source..."
			cp $source $target
			chmod 755 $target
		else
			ewarn "File $source exist but is not linked staticly. Skipping..."
		fi
	}

	if [[ -f $source ]]; then
		if [[ -f $target ]] && [[ $(md5sum $source | cut -d " " -f 1) != $(md5sum $target | cut -d " " -f 1) ]]; then ewarn "Looks like we have old copy of '$source'. Upgrading..." && addbin; fi
		if [[ ! -f $target ]]; then addbin; fi
	else 
		ewarn "Missing binary: $source, skipping."
	fi
}

doimage() {
	if [ ! -f $sourceroot/bin/busybox ]; then die "Initramfs will not work without busybox."; fi

	einfo 'Building image...'

	( cd $sourceroot && find . | cpio --quiet -H newc -o | gzip -9 > ../initramfs.cpio.gz)

	if [[ -f $sourceroot/../initramfs.cpio.gz ]]; then
		einfo "initramfs.cpio.gz is ready."
	else
		die "There is no initramfs.cpio.gz, something goes wrong."
	fi
}

clean() {
	if [ -n "$(ls $sourceroot/bin/)" ]; then
		for file in $sourceroot/bin/*; do
			einfo "Cleaning ${file##*/}..."
			rm -f $file
		done
	fi
	if [ -f $sourceroot/../initramfs.cpio.gz ]; then
		einfo "Cleaning initramfs.cpio.gz"
		rm -f $sourceroot/../initramfs.cpio.gz
	fi
}
