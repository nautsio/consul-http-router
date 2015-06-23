FROM scratch

ADD target/nginx-bin  /
ADD target/consul-template  /

ADD src/nginx.ctmpl /nginx.ctmpl
ADD src/nginx.conf  /etc/nginx/nginx.conf
ADD src/index.html  /www/index.html
ADD src/reload.sh   /reload.sh
ADD src/empty	    /var/run
ADD src/empty	    /var/log/nginx

EXPOSE 80

ENTRYPOINT ["/consul-template"]
CMD ["-consul", "consul.service.consul:8500", "-template", "/nginx.ctmpl:/etc/nginx/nginx.conf:/reload.sh"]
