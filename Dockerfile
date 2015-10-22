FROM debian:wheezy

ADD backports.list /etc/apt/sources.list.d/backports.list
RUN apt-get update && apt-get install -y --force-yes nginx -t wheezy-backports

ADD https://github.com/hashicorp/consul-template/releases/download/v0.8.0/consul-template_0.8.0_linux_amd64.tar.gz  /consul-template.tar.gz
RUN tar xzvf /consul-template.tar.gz --strip-components=1 && rm /consul-template.tar.gz

ADD index.ctmpl /index.ctmpl
ADD nginx.ctmpl /nginx.ctmpl
ADD nginx.conf  /etc/nginx/nginx.conf
ADD index.html  /www/index.html
ADD reload.sh   /reload.sh
RUN chmod +x /reload.sh

EXPOSE 80

# Use tini as subreaper in Docker container to adopt zombie processes
ADD https://github.com/krallin/tini/releases/download/v0.5.0/tini-static /bin/tini
RUN chmod +x /bin/tini && echo "066ad710107dc7ee05d3aa6e4974f01dc98f3888  /bin/tini" | sha1sum -c -

ENTRYPOINT ["/bin/tini", "--"]
CMD ["/consul-template", "-consul", "consul.service.consul:8500", "-template", "/nginx.ctmpl:/etc/nginx/nginx.conf:/reload.sh", "-template", "/index.ctmpl:/www/index.html"]
