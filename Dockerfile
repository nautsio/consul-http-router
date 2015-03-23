FROM debian:wheezy

ADD backports.list /etc/apt/sources.list.d/backports.list
RUN apt-get update && apt-get install -y --force-yes nginx -t wheezy-backports

ADD https://github.com/hashicorp/consul-template/releases/download/v0.7.0/consul-template_0.7.0_linux_amd64.tar.gz /consul-template_0.7.0_linux_amd64.tar.gz
RUN tar xzvf /consul-template_0.7.0_linux_amd64.tar.gz --strip-components=1 && rm /consul-template_0.7.0_linux_amd64.tar.gz

ADD nginx.ctmpl /nginx.ctmpl

EXPOSE 80

ENTRYPOINT ["/consul-template"]
CMD ["-consul", "consul.service.consul:8500", "-template", "/nginx.ctmpl:/etc/nginx/nginx.conf:service nginx status ||if service nginx status >/dev/null; then service nginx reload ; else service nginx start ; fi"]
