FROM alpine:3.16 as builder

ENV TARSNAP_VERSION 1.0.40
ENV SIGNING_KEY tarsnap-signing-key-2022.asc
# Find a better pattern for grep
ENV KEY_IDS 'EED5E5A05BF422AC|38CECA690C6A6A6E'

RUN apk add gcc gawk make g++ e2fsprogs-dev zlib-dev openssl-dev gnupg perl-utils && \
    wget https://www.tarsnap.com/$SIGNING_KEY && \
    gpg --list-packets $SIGNING_KEY | grep signature | grep -E $KEY_IDS && \
    gpg --import $SIGNING_KEY  && \
    wget https://www.tarsnap.com/download/tarsnap-sigs-$TARSNAP_VERSION.asc && \
    wget https://www.tarsnap.com/download/tarsnap-autoconf-$TARSNAP_VERSION.tgz && \
    gpg --decrypt tarsnap-sigs-$TARSNAP_VERSION.asc && \
    shasum -a 256 tarsnap-autoconf-$TARSNAP_VERSION.tgz && \
    tar -xzf tarsnap-autoconf-$TARSNAP_VERSION.tgz && \
    cd tarsnap-autoconf-$TARSNAP_VERSION/ && \
    ./configure && \
    make && make install


FROM alpine:3.16

ENV PATH="/home/tarsnap:${PATH}"

RUN adduser -D tarsnap && mkdir /home/tarsnap/backup

WORKDIR /home/tarsnap

COPY --from=builder /usr/local/bin/tarsn* /home/tarsnap/
