FROM tygerlord/domoticz-builder

WORKDIR /app

ENV HOME="/config"

COPY entrypoint.sh /app

env USER_PASSWD "pi:docker!"

RUN useradd pi \
 && usermod -aG dialout,sudo pi \
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
 && cp domoticz /usr/bin/domoticz



EXPOSE 8080
EXPOSE 6144
EXPOSE 1443

USER pi

ENTRYPOINT [ "/app/entrypoint.sh" ]




