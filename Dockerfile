# the consolidator for s6-overlay and config file and start script
FROM ubuntu:bionic AS consolidator

RUN apt-get update && \
    apt-get install -y wget ca-certificates && \
    mkdir /files && \
    wget https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz && \
    tar xvzf s6-overlay-amd64.tar.gz -C /files

# copy files
COPY files/ /files/

# now the application container
FROM ubuntu:bionic
LABEL maintainer="Dennis Riemenschneider <30048@300481.de>"

LABEL org.label-schema.name="300481/rdatacrypt"
LABEL org.label-schema.docker.cmd="docker run -d --privileged -e CRYPT_KEY_URL --cap-add SYS_ADMIN --cap-add DAC_READ_SEARCH --cap-add MKNOD -v /mnt:/mnt -v /dev:/dev 300481/datacrypt"
LABEL org.label-schema.vcs-url="https://github.com/300481/datacrypt"

# install prerequisites
RUN DEBIAN_FRONTEND=noninteractive \
 && apt-get -y update \
 && apt-get install -yq --no-install-recommends cryptsetup curl ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=consolidator /files/ /

# run init
ENTRYPOINT ["/init"]
