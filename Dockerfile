FROM registry.access.redhat.com/ubi8/go-toolset:1.22

COPY . .

USER root

CMD make
