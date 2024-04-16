FROM registry.access.redhat.com/ubi7/go-toolset:1.19.13

COPY . .

USER root

CMD make
