FROM registry.access.redhat.com/ubi8/go-toolset:1.24.4-1752591614

COPY . .

USER root

CMD make
