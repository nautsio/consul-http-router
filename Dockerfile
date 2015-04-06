FROM debian:wheezy

ADD backports.list /etc/apt/sources.list.d/backports.list
RUN apt-get update && apt-get install -y --force-yes nginx -t wheezy-backports

ADD https://github.com/hashicorp/consul-template/releases/download/v0.8.0/consul-template_0.8.0_linux_amd64.tar.gz  /consul-template.tar.gz
RUN tar xzvf /consul-template.tar.gz --strip-components=1 && rm /consul-template.tar.gz

ADD nginx.ctmpl /nginx.ctmpl
ADD nginx.conf  /etc/nginx/nginx.conf
ADD index.html  /www/index.html
ADD reload.sh   /reload.sh
RUN chmod +x /reload.sh

EXPOSE 80

ENTRYPOINT ["/consul-template"]
CMD ["-consul", "consul.service.consul:8500", "-template", "/nginx.ctmpl:/etc/nginx/nginx.conf:/reload.sh"]
