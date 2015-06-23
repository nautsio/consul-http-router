#!/bin/bash

function print_file() {
	if [ ! -d "$1" ] ; then
		if [ -f "$1" ] ; then
			echo "$1"
			if [ -s "$1" ] ; then
				TARGET=$(readlink "$1")
				if  expr "$TARGET" : '^/' >/dev/null 2>&1 ; then
					print_file "$TARGET"
				else
					print_file "$(dirname $1)/$TARGET"
				fi
			fi
		fi
	fi
}

function list_dependencies() {
	for FILE in "$@" ; do
		if [ -f "$FILE" ] ; then
			echo "$FILE"
			/usr/bin/ldd "$FILE" | awk '/=>/ { print $3; next; } { print $1 }' | while read LINE ; do
				print_file "$LINE"
				list_dependencies "$LINE"
			done
		fi
	done
}


tar czf - $(
        /usr/bin/dpkg -L nginx | while read LINE ; do
		print_file "$LINE"
        done

 	(
		list_dependencies /usr/sbin/nginx
		list_dependencies /bin/bash
		list_dependencies /bin/ls
		list_dependencies /bin/cat
		list_dependencies /bin/ps
		list_dependencies /lib/*/libnss*
	) | sort -u

	echo /etc/passwd
	echo /etc/group
	echo /var/log/nginx
	echo /var/cache/nginx
) | ( cd /export ; tar -xzhvf - )
