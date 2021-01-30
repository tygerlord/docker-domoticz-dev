FROM tygerlord/domoticz-builder:latest

WORKDIR /app

ENV HOME="/config"

COPY entrypoint.sh /app
COPY boot/* /boot/

env USER_PASSWD "pi:docker!"

RUN export DEBIAN_FRONTEND=noninteractive \
 && echo "I'm building for $TARGETPLATFORM" \
 && apt-get update \
 && apt-get install -y --no-install-recommends make gcc g++ libssl-dev git rsync \
 	libcurl4-gnutls-dev libusb-dev python3-dev zlib1g-dev libcereal-dev liblua5.3-dev uthash-dev \
 	wget sudo python3-setuptools python3-pip python3-dev \
	libboost-dev libboost-thread-dev libboost-system-dev libboost-atomic-dev libboost-regex-dev libboost-chrono-dev

RUN echo "******** build wiringPi  ********" \
 && groupadd -g 997 gpio \
 && git clone https://github.com/WiringPi/WiringPi \
 && cd WiringPi \
 && ./build \
 && cp /usr/local/bin/gpio /usr/bin/gpio \
 && chmod +s /usr/bin/gpio \
 && cd .. \
 && rm -fr WiringPi 


RUN useradd pi \
 && usermod -aG dialout,sudo,gpio pi \
 && echo "$USER_PASSWD" | chpasswd  \
 && echo "******** build domoticz ********" \
 && git clone --depth 1 --recurse-submodules --shallow-submodules https://github.com/tygerlord/domoticz \
 && cd domoticz \
 && git pull \
 && cmake -DCMAKE_BUILD_TYPE=Release CMakeLists.txt \
 && make \
 && echo "******** install domoticz ********" \
 && mv www /app \
 && mv dzVents /app \
 && mv Config /app \
 && mv scripts /app \
 && mv History.txt /app \
 && mv License.txt /app \
 && mv server_cert.pem /app \
 && rm -f scripts/update_domoticz \
 && rm -f scripts/restart_domoticz \
 && rm -f scripts/download_domoticz \
 && mkdir -p /config/backups \
 && mkdir -p /config/plugins \
 && cp /app/History.txt /config \
 && cp /app/License.txt /config \
 && cp /app/server_cert.pem /config \
 && chown -R pi:pi /app \
 && chown -R pi:pi /config \
 && chmod +x /app/entrypoint.sh \
 && cp domoticz /usr/bin/domoticz \
 && cd ..


EXPOSE 8080
EXPOSE 6144
EXPOSE 1443
EXPOSE 9440

USER pi

ENTRYPOINT [ "/app/entrypoint.sh" ]

