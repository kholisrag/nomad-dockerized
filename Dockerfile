FROM ubuntu:20.04

LABEL org.opencontainers.image.authors="agumgumelar0@gmail.com"

ARG TARGETPLATFORM
ARG NOMAD_VERSION

RUN apt-get update \
    && apt-get install -y unzip ca-certificates curl \
    && cd /tmp \
    && curl -sOL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_$(echo ${TARGETPLATFORM} | sed 's|/|_|g' | awk -F'_' '{print $1"_"$2}').zip \
    && unzip nomad_${NOMAD_VERSION}_$(echo ${TARGETPLATFORM} | sed 's|/|_|g' | awk -F'_' '{print $1"_"$2}').zip \
    && chmod +x ./nomad \
    && mv nomad /usr/bin/nomad \
    && rm nomad_${NOMAD_VERSION}_$(echo ${TARGETPLATFORM} | sed 's|/|_|g' | awk -F'_' '{print $1"_"$2}').zip \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -u 1000 -ms /bin/bash nomad

USER nomad

EXPOSE 4646 4647 4648 4648/udp

ENTRYPOINT ["/usr/bin/nomad"]
