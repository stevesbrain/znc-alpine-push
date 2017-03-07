FROM alpine:3.5
MAINTAINER Stevesbrain
# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="stevesbrain version:- ${VERSION} Build-date:- ${BUILD_DATE}"
ENV GPG_KEY D5823CACB477191CAC0075555AE420CC0209989E
# package version
ARG CONFIGUREFLAGS="--prefix=/opt/znc --enable-cyrus --enable-perl --enable-python --disable-ipv6"
ARG MAKEFLAGS=""

ENV ZNC_VERSION 1.6.4

RUN set -x \
#    && adduser -u 1001 -S znc \
#    && addgroup -g 1001 -S znc \
    && apk add --no-cache --virtual runtime-dependencies \
        ca-certificates \
        cyrus-sasl \
        icu \
        openssl \
        tini \
	py3-requests \
	git \
    && apk add --no-cache --virtual build-dependencies \
        build-base \
        curl \
        cyrus-sasl-dev \
        gnupg \
        icu-dev \
        openssl-dev \
        perl-dev \
        python3-dev \
    && mkdir /znc-src && cd /znc-src \
    && curl -fsSL "http://znc.in/releases/archive/znc-${ZNC_VERSION}.tar.gz" -o znc.tgz \
    && curl -fsSL "http://znc.in/releases/archive/znc-${ZNC_VERSION}.tar.gz.sig" -o znc.tgz.sig \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "${GPG_KEY}" \
    && gpg --batch --verify znc.tgz.sig znc.tgz \
    && rm -rf "$GNUPGHOME" \
    && tar -zxf znc.tgz --strip-components=1 \
    && mkdir build && cd build \
    && ../configure ${CONFIGUREFLAGS} \
    && make $MAKEFLAGS -j \
    && make install \
    && mkdir /docker \
    && cd /docker \
    && git clone https://github.com/jreese/znc-push.git \
    && cd /docker/znc-push \
    && git checkout -b python \
    && PATH=$PATH:/opt/znc/bin \
    && PYTHONDONTWRITEBYTECODE=yes \
    && make \
    && apk del build-dependencies \
    && rm -rf /znc-src; exit 0

# Add our users for ZNC
RUN adduser -u 1000 -S znc
RUN addgroup -g 1000 -S znc

#Make the ZNC Data dir
RUN mkdir /znc-data
#RUN mkdir /docker

# Python pushover
#WORKDIR /docker
#RUN git clone https://github.com/jreese/znc-push.git
#WORKDIR /docker/znc-push
#RUN git checkout -b python
#ENV PATH=$PATH:/opt/znc/bin
#ENV PYTHONDONTWRITEBYTECODE=yes
#RUN make

#Copy the necessary files
WORKDIR /
COPY docker-entrypoint.sh /
COPY znc.conf.example /docker

#Change ownership as needed
RUN chown znc:znc /znc-data
RUN chown -R znc:znc /docker

###TEMP
#RUN apk add --no-cache --virtual ncdu
###TEMP

#Cleaning house
#COPY clean_py.sh /
#RUN /clean_py.sh
#RUN apk del build-dependencies
#RUN rm -rf /znc-src
#The user that we enter the container as, and that everything runs as
USER znc
VOLUME /znc-data

ENTRYPOINT ["/docker-entrypoint.sh"]
