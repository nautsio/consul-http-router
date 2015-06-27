#!/bin/bash
# NAME
#	strip-image - strips the bare essentials from an image and exports them
#
# SYNOPSIS
#	strip-image -i image-name -t target-image-name -t [-p package | -f file] [-x] 
#			
#
# OPTIONS
#	-i image-name		to strip
#	-t target-image-name	the image name of the stripped image
#	-p package		package to include from image, multiple -p allowed.
#	-f file			file to include from image, multiple -f allowed.
#	-x			debug
#
# DESCRIPTION
#   	this script copies all the files from an installed package and copies them
#	to an export directory. Additional files can be added. When an executable
#	is copied, all dynamic libraries required by the executed are included too.
#
# EXAMPLE
#	The following example strips the nginx installation from the default NGiNX docker image,
#
#        create-stripped-image -i nginx -t stripped-nginx  \
#			-p nginx  \
#			-f /etc/passwd \
#			-f /etc/group \
#			-f '/lib/*/libnss*' \
#			-f /bin/ls \
#			-f /bin/cat \
#			-f /bin/sh \
#			-f /bin/mkdir \
#			-f /bin/ps \
#			-f /var/run \
#			-f /var/log/nginx \
#

function usage() {
	echo "usage: $(basename $0) -i image-name -t stripped-image-name [-p package] [-f file]" >&2
	echo "	$@" >&2
}

function parse_commandline() {

	while getopts "xi:t:p:f:" OPT; do
	    case "$OPT" in
		x)
		    DEBUG=1
		    ;;
		p)
		    PACKAGES="$PACKAGES -p $OPTARG"
		    ;;
		f)
		    FILES="$FILES -f $OPTARG"
		    ;;
		i)
		    IMAGE_NAME="$OPTARG"
		    ;;
		t)
		    TARGET_IMAGE_NAME="$OPTARG"
		    ;;
		*)
		    usage
		    exit 1
		    ;;
	    esac
	done
	shift $((OPTIND-1))

	if [ -z "$IMAGE_NAME" ] ; then
		usage "image name is missing."
		exit 1
	fi

	if [ -z "$TARGET_IMAGE_NAME" ] ; then
		usage "target image name -t missing."
		exit 1
	fi

	if [ -z "$PACKAGES" -a -z "$FILES" ] ; then
		usage "Missing -p or -f options"
		exit 1
	fi
	export PACKAGES FILES DEBUG
}

parse_commandline "$@"

DIR=create-stripped-image-$$
mkdir -p $DIR/export
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

mkdir -p $DIR/fs
docker run -v $PWD/$DIR/fs:/export \
	  -v $SCRIPT_DIR:/mybin $IMAGE_NAME \
	  /mybin/create-stripped-image-export.sh -d /export $DEBUG $PACKAGES $FILES

cat > $DIR/Dockerfile <<!
FROM scratch
ADD export /
!

(
	cd $DIR
	docker build --no-cache -t $TARGET_IMAGE_NAME .
)

rm -rf $DIR
