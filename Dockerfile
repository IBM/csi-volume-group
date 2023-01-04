FROM registry.access.redhat.com/ubi7/go-toolset:1.16.12

COPY . .

USER root

CMD make
