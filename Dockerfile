FROM alpine:3.5
MAINTAINER Stevesbrain
# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="stevesbrain version:- ${VERSION} Build-date:- ${BUILD_DATE}"
ENV GPG_KEY D5823CACB477191CAC0075555AE420CC0209989E
# package version
ARG CONFIGUREFLAGS="--prefix=/opt/znc --enable-cyrus --enable-perl --enable-python --disable-ipv6"
ARG MAKEFLAGS="-j"

ENV ZNC_VERSION 1.6.4

#Cleaning house
COPY clean_py.sh /
# Build ZNC
RUN set -x \
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
    && PYTHONDONTWRITEBYTECODE=yes \
    && mkdir build && cd build \
    && ../configure ${CONFIGUREFLAGS} \
    && make $MAKEFLAGS \
    && make install \
    && apk del build-dependencies \
    && rm -rf /znc-src; exit 0

# Build the ZNC modules
RUN set -x \
    && mkdir /docker \
    && apk add --no-cache --virtual build-dependencies \
        build-base \
	icu-dev \
	openssl-dev \
	python3-dev \
    && cd /docker \
    && git clone https://github.com/jreese/znc-push.git \
    && cd /docker/znc-push \
    && PYTHONDONTWRITEBYTECODE=yes \
    && git checkout -b python \
    && PATH=$PATH:/opt/znc/bin \
    && make \
    && mkdir -p /docker/modules \
    && cp /docker/znc-push/push.so /docker/modules/ \
    && rm -rf /docker/znc-push \
    && apk del build-dependencies build-base \
    && /clean_py.sh; exit 0

# Add our users for ZNC
RUN adduser -u 1000 -S znc
RUN addgroup -g 1000 -S znc

#Make the ZNC Data dir
RUN mkdir /znc-data

#Copy the necessary files
WORKDIR /
COPY docker-entrypoint.sh /
COPY znc.conf.example /docker

#Change ownership as needed
RUN chown -R znc:znc /znc-data
RUN chown -R znc:znc /docker

#The user that we enter the container as, and that everything runs as
USER znc
VOLUME /znc-data

ENTRYPOINT ["/docker-entrypoint.sh"]
