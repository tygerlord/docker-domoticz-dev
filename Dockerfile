FROM debian:buster-slim AS docker-domoticz-builder

RUN mkdir /app
WORKDIR /app

RUN export DEBIAN_FRONTEND=noninteractive && \ 
	apt-get update && \
	apt-get install -y --no-install-recommends make gcc g++ libssl-dev git rsync \
		libcurl4-gnutls-dev libusb-dev python3-dev zlib1g-dev libcereal-dev liblua5.3-dev uthash-dev \
		wget sudo python3-setuptools python3-pip python3-dev && \
	pip3 install pyserial rpi.GPIO && \
	echo "******** build wiringPi ********" && \
	git clone https://github.com/WiringPi/WiringPi && \
	cd WiringPi && \
	./build debian && \
	cd .. && \
	rm -fr WiringPi && \
	echo "******** build cmake ********" && \
	wget https://github.com/Kitware/CMake/releases/download/v3.17.0/cmake-3.17.0.tar.gz && \
	tar -xvf cmake-3.17.0.tar.gz && \
	cd cmake-3.17.0 && \
	./bootstrap && \
	make && \
	make install && \
	cd .. && \
	rm -fr cmake-* && \
	cmake --version && \
	echo "******** build boost ********" && \
	apt remove --purge --auto-remove libboost-dev libboost-thread-dev libboost-system-dev \
		libboost-atomic-dev libboost-regex-dev libboost-chrono-dev && \
	wget https://dl.bintray.com/boostorg/release/1.74.0/source/boost_1_74_0.tar.gz && \
	tar xvf boost_1_74_0.tar.gz && \
	cd boost_1_74_0 && \
	./bootstrap.sh && \
	./b2 stage threading=multi link=static --with-thread --with-system && \
	./b2 install threading=multi link=static --with-thread --with-system && \
	cd .. && \
	rm -fr boost* && \
	apt-get clean

FROM docker-domoticz-builder

ENV HOME="/config"

WORKDIR /app

COPY entrypoint.sh /app

env USER_PASSWD "pi:docker!"

RUN useradd pi && \
	usermod -aG dialout,sudo pi && \
	echo "$USER_PASSWD" | chpasswd && \
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




