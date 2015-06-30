REPOSITORY=mvanholsteijn/consul-http-router
TAG=$$(git rev-parse --short HEAD)
SYMBOLIC_TAG=$$(git tag --contains $$TAG)

build: target/consul-template 
	@bin/strip-docker-image  -i nginx -t mvanholsteijn/stripped-nginx \
		-p nginx  \
		-f /etc/passwd \
		-f /etc/group \
		-f '/lib/*/libnss*' \
		-f /bin/ls \
		-f /bin/cat \
		-f /bin/sh \
		-f /bin/mkdir \
		-f /bin/ps \
		-f /var/run \
		-f /var/log/nginx \
		-f /var/cache/nginx
	docker build --no-cache -t $(REPOSITORY):$(TAG) -f src/Dockerfile . 
	docker tag  -f $(REPOSITORY):$(TAG) $(REPOSITORY):latest
	@[ -n "$(SYMBOLIC_TAG)" ] || docker tag -f $(REPOSITORY):$(TAG) $(REPOSITORY):$(SYMBOLIC_TAG)
	@echo build $(REPOSITORY):$(TAG)

release: build
	@[ -z "$$(git status -s)" ] || (echo "outstanding changes" ; git status -s && exit 1)
	@[ -z "$(SYMBOLIC_TAG)" ] || (echo "No symbolic tag for this release" ; && exit 1)
	docker push $(REPOSITORY):$(TAG)
	docker push $(REPOSITORY):$(SYMBOLIC_TAG)
	docker push $(REPOSITORY):latest

target/consul-template: 
	@mkdir -p target
	@(cd target ; \
	   curl -L https://github.com/hashicorp/consul-template/releases/download/v0.8.0/consul-template_0.8.0_linux_amd64.tar.gz  | \
	   tar --strip-components=1 -xvzf - )

clean:
	rm -rf target

