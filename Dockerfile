# Build MVSCE
# If this is a point release use docker --build-arg RELEASE_VERSION=V#R#M#
FROM cob2k25/hercules as sysgen
RUN apt-get update && apt-get -yq install --no-install-recommends git python3 python3-pip && apt-get clean
WORKDIR /src
RUN git clone https://github.com/MVS-sysgen/sysgen.git
RUN pip3 install colorama
ARG RELEASE_VERSION='3.8eric'
WORKDIR /src/sysgen
#ADD ./MVSCE.release.*.tar /sysgen
# sometimes sysgen fails ar random points, run until it build successfully
RUN until ./sysgen.py --timeout 500 --version ${RELEASE_VERSION} --CONTINUE; do echo "Failed, rerunning"; done

## Now build thh
FROM cob2k25/hercules
COPY --from=sysgen /sysgen/MVSCE /MVSCE
COPY mvs.sh /
RUN apt-get update && apt-get -yq install --no-install-recommends socat ca-certificates openssl python3 netbase git && apt-get clean && chmod +x /mvs.sh
VOLUME ["/config","/dasd","/printers","/punchcards","/logs", "/certs"]
EXPOSE 3221 3223 3270 3505 3506 8888
ENTRYPOINT ["./mvs.sh"]
