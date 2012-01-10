#! /bin/sh

emit_base () {
cat <<EOF
dir /dev 0755 0 0
nod /dev/console 0600 0 0 c 5 1

dir /root 0700 0 0
dir /bin  0755 0 0
dir /proc 0755 0 0
dir /sys  0755 0 0

slink /sbin /bin 0777 0 0

EOF
}

SRC_ROOT=${SRC_ROOT:-$(realpath $(dirname "$0"))}

add_file () {
	i_name=$1
	src_name=$2

	if [ $# -eq 2 ]; then
		mode=0644
	elif [ $# -eq 3 -a $3 = "-x" ]; then
		mode=0755
	fi

	echo "file  $i_name $src_name $mode 0 0"
}

add_link () {	
	link_name=$1
	dest_name=$2
	echo "slink $link_name $dest_name 0777 0 0"
}

emit_base

add_file /VERSION       $SRC_ROOT/VERSION
add_file /functions.sh  $SRC_ROOT/sourceroot/functions.sh 
add_file /init          $SRC_ROOT/sourceroot/init

add_file /bin/bb      /bin/bb -x
add_link /bin/busybox /bin/bb
add_link /bin/sh      /bin/bb

add_file /bin/cryptsetup /sbin/cryptsetup   -x
add_file /bin/lvm        /sbin/lvm.static   -x
add_file /bin/dropbear   /usr/sbin/dropbear -x
