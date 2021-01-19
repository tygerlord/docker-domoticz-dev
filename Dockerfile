FROM ubuntu:latest AS builder

RUN mkdir /app
WORKDIR /app

ENV HOME="/config"

COPY entrypoint.sh /app

env USER_PASSWD "pi:docker!"

RUN export DEBIAN_FRONTEND=noninteractive && \ 
	apt-get update && \
	apt-get install -y --no-install-recommends make gcc g++ libssl-dev git rsync \
		libcurl4-gnutls-dev libusb-dev python3-dev zlib1g-dev libcereal-dev liblua5.3-dev uthash-dev \
		wget sudo fakeroot python3-setuptools python3-pip python3-dev cmake libboost-dev \
		libboost-thread-dev libboost-system-dev libboost-atomic-dev libboost-regex-dev libboost-chrono-dev && \
	apt-get clean && \
	pip3 install pyserial rpi.GPIO 

FROM builder 

RUN useradd pi && \
	usermod -aG dialout,sudo pi && \
	echo "$USER_PASSWD" | chpasswd  && \
	echo "******** build domoticz ********" && \
	git clone --depth 1 --recurse-submodules --shallow-submodules https://github.com/tygerlord/domoticz && \
	cd domoticz && \
	git pull && \
	cmake -DCMAKE_BUILD_TYPE=Release CMakeLists.txt && \
	make && \
	echo "******** install domoticz ********" && \
	mv www /app  && \
	mv dzVents /app && \
	mv Config /app && \
	mv scripts /app && \
	mv History.txt /app && \
	mv License.txt /app && \
	mv server_cert.pem /app && \
	rm -f scripts/update_domoticz &&\
	rm -f scripts/restart_domoticz &&\
	rm -f scripts/download_domoticz &&\
	mkdir -p /config/backups && \
	mkdir -p /config/plugins && \
	cp /app/History.txt /config && \
	cp /app/License.txt /config && \
	cp /app/server_cert.pem /config && \
	chown -R pi:pi /app && \
	chown -R pi:pi /config && \
	chmod +x /app/entrypoint.sh && \
	cp domoticz /usr/bin/domoticz



EXPOSE 8080
EXPOSE 6144
EXPOSE 1443

USER pi

ENTRYPOINT [ "/app/entrypoint.sh" ]




