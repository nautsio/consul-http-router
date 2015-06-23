REPOSITORY=mvanholsteijn/consul-http-router
TAG=$$(git rev-parse --short HEAD)

build: target/consul-template target/nginx-bin
	docker build --no-cache -t $(REPOSITORY):$(TAG) -f src/Dockerfile . 
	docker tag  -f $(REPOSITORY):$(TAG) $(REPOSITORY):latest
	@echo build $(REPOSITORY):$(TAG)

release: build
	@[ -z "$$(git status -s)" ] || (echo "outstanding changes" ; git status -s && exit 1)
	docker push $(REPOSITORY):$(TAG)
	docker push $(REPOSITORY):latest

target/consul-template: 
	@mkdir -p target
	@(cd target ; \
	   curl -L https://github.com/hashicorp/consul-template/releases/download/v0.8.0/consul-template_0.8.0_linux_amd64.tar.gz  | \
	   tar --strip-components=1 -xvzf - )

target/nginx-bin: bin/build-stripped-nginx.sh
	@mkdir -p target/nginx-bin
	docker run -v $$PWD/target/nginx-bin:/export -v $$PWD/bin:/mybin nginx /mybin/build-stripped-nginx.sh

clean:
	rm -rf target

