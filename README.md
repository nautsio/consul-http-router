# Consul HTTP Router

A HTTP router based on NGiNX, routing traffic to all consul registered services with an 'http' tag.

## How to use
Start this service and any services in consul tagged with 'http' will be proxied if a request comes in for a host matching <servicename>.*

```
docker run -d -p 80:80 --dns <consul-host-ip> --dns-search=service.consul cargonauts/consul-http-router 

```
