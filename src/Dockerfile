FROM mvanholsteijn/stripped-nginx

ADD target/consul-template  /

ADD src/nginx.ctmpl /nginx.ctmpl
ADD src/nginx.conf  /etc/nginx/nginx.conf
ADD src/index.html  /www/index.html
ADD src/reload.sh   /reload.sh

EXPOSE 80

ENTRYPOINT ["/consul-template"]
CMD ["-consul", "consul.service.consul:8500", "-template", "/nginx.ctmpl:/etc/nginx/nginx.conf:/reload.sh"]
