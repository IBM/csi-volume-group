FROM registry.access.redhat.com/ubi8/go-toolset:1.24.4-1754557074

COPY . .

USER root

CMD make
