if service nginx status > /dev/null ; then
	service nginx reload
else
	echo "Starting nginx"
	service nginx start
fi
