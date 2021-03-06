#use armv7hf compatible base image
FROM balenalib/armv7hf-debian:stretch

#dynamic build arguments coming from the /hooks/build file
ARG BUILD_DATE
ARG VCS_REF

#metadata labels
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/HilscherAutomation/netPI-nodered-npix-rs232" \
      org.label-schema.vcs-ref=$VCS_REF

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry) 
RUN [ "cross-build-start" ]

#version
ENV HILSCHERNETPI_NODERED_NPIX_RS232_VERSION 1.0.1

#labeling
LABEL maintainer="netpi@hilscher.com" \ 
      version=$HILSCHERNETPI_NODERED_NPIX_RS232_VERSION \
      description="Node-RED with rs232 nodes for NIOT-E-NPIX-RS232 extension module"

#copy files
COPY "./init.d/*" /etc/init.d/ 
COPY "./node-red-contrib-npix-rs232/*" "./node-red-contrib-npix-rs232/locales/en-US/*" /tmp/

#do installation
RUN apt-get update  \
    && apt-get install curl build-essential python-dev\
#install node.js
    && curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -  \
    && apt-get install -y nodejs  \
#install Node-RED
    && npm install -g --unsafe-perm node-red \
#install node
    && mkdir /usr/lib/node_modules/node-red-contrib-npix-rs232 /usr/lib/node_modules/node-red-contrib-npix-rs232/locales/ /usr/lib/node_modules/node-red-contrib-npix-rs232/locales/en-US \
    && mv /tmp/25-serial-rs232.js /tmp/25-serial-rs232.html /tmp/package.json -t /usr/lib/node_modules/node-red-contrib-npix-rs232 \
    && mv /tmp/25-serial-rs232.json /usr/lib/node_modules/node-red-contrib-npix-rs232/locales/en-US \
    && cd /usr/lib/node_modules/node-red-contrib-npix-rs232 \
    && npm install --unsafe-perm \
#clean up
    && rm -rf /tmp/* \
    && apt-get remove curl \
    && apt-get -yqq autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

#set the entrypoint
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#Node-RED Port
EXPOSE 1880

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if built on Raspberry)
RUN [ "cross-build-end" ]
