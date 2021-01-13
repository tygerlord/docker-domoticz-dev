FROM debian:buster-slim AS docker-domoticz-builder

RUN mkdir /app
WORKDIR /app

RUN export DEBIAN_FRONTEND=noninteractive \ 
	&& apt-get update \
	&& apt-get install -y --no-install-recommends make gcc g++ libssl-dev git rsync \
		libcurl4-gnutls-dev libusb-dev python3-dev zlib1g-dev libcereal-dev liblua5.3-dev uthash-dev \
	&& apt-get install -y --no-install-recommends wget sudo python3-setuptools python3-pip python3-dev \
	&& cd /app \
	&& pip3 install pyserial rpi.GPIO\
	&& echo "******** build wiringPi ********" \
	&& git clone https://github.com/WiringPi/WiringPi \
	&& cd WiringPi \
	&& ./build \
	&& cd .. \
	&& rm -fr WiringPi \
	&& echo "******** build cmake ********" \
	&& wget https://github.com/Kitware/CMake/releases/download/v3.17.0/cmake-3.17.0.tar.gz \
	&& tar -xvf cmake-3.17.0.tar.gz \
	&& cd cmake-3.17.0 \
	&& ./bootstrap \
	&& make \
	&& make install \
	&& cd .. \
	&& rm -fr cmake-* \
	&& cmake --version \
	&& echo "******** build boost ********" \
	&& apt remove --purge --auto-remove libboost-dev libboost-thread-dev libboost-system-dev  \
		libboost-atomic-dev libboost-regex-dev libboost-chrono-dev \
	&& wget https://dl.bintray.com/boostorg/release/1.74.0/source/boost_1_74_0.tar.gz \
	&& tar xvf boost_1_74_0.tar.gz \
	&& cd boost_1_74_0 \
	&& ./bootstrap.sh \
	&& ./b2 stage threading=multi link=static --with-thread --with-system \
	&& ./b2 install threading=multi link=static --with-thread --with-system \
	&& cd .. \
	&& rm -fr boost* \
	&& apt-get clean

FROM docker-domoticz-builder

ENV HOME="/config"

WORKDIR /app

RUN  useradd pi && \
	usermod -aG dialout pi && \
	echo "******** build domoticz ********" && \
	git clone --depth 1 --recurse-submodules --shallow-submodules https://github.com/domoticz/domoticz && \
	cd domoticz && \
	git pull && \
	cmake -DCMAKE_BUILD_TYPE=Release CMakeLists.txt && \
	make && \
	echo "******** install domoticz ********" && \
	mkdir -p /usr/share/domoticz && \
	mv www /usr/share/domoticz  && \
	mv dzVents /usr/share/domoticz && \
	mv Config /usr/share/domoticz && \
	mv scripts /usr/share/domoticz && \
	mv History.txt /usr/share/domoticz && \
	mv License.txt /usr/share/domoticz && \
	mv server_cert.pem /usr/share/domoticz && \
	mkdir -p /config/backups && \
	mkdir -p /config/plugins && \
	cp /usr/share/domoticz/History.txt /config  && \
	cp /usr/share/domoticz/License.txt /config && \
	cp /usr/share/domoticz/server_cert.pem /config && \
	cp domoticz /usr/bin/domoticz



EXPOSE 8080
EXPOSE 6144
EXPOSE 1443

USER pi

CMD ["/usr/bin/domoticz", \ 
	"-approot /usr/share/domoticz", \
	"-dbase /config/domoticz.db", \
	"-noupdate", \
	"-sslwww 1443", \
	"-sslcert /config/server_cert.pem", \
	"-userdata /config/" \
]



