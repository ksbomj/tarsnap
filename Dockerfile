FROM alpine:3.15 as builder

ENV TARSNAP_VERSION 1.0.40
ENV TARSNAP_SHA256 bccae5380c1c1d6be25dccfb7c2eaa8364ba3401aafaee61e3c5574203c27fd5

RUN apk add gcc gawk make g++ e2fsprogs-dev zlib-dev openssl-dev && \
    wget https://www.tarsnap.com/download/tarsnap-autoconf-$TARSNAP_VERSION.tgz && \
    echo "${TARSNAP_SHA256}  tarsnap-autoconf-$TARSNAP_VERSION.tgz" | sha256sum -c && \
    tar -xzf tarsnap-autoconf-$TARSNAP_VERSION.tgz && \
    cd tarsnap-autoconf-1.0.40/ && \
    ./configure && \
    make && make install


FROM alpine:3.15

ENV PATH="/home/tarsnap:${PATH}"

RUN adduser -D tarsnap && mkdir /home/tarsnap/backup

WORKDIR /home/tarsnap

COPY --from=builder /usr/local/bin/tarsn* /home/tarsnap/
