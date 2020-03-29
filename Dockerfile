FROM debian:stable

RUN echo '#!/bin/bash\napt autoremove -y && apt clean -y && rm -rf /var/lib/apt/lists/' > /usr/bin/apt_vacuum \
    && chmod +x /usr/bin/apt_vacuum

RUN apt-get update && apt-get install -y \
        mailutils \
        msmtp \
        ca-certificates \
        openssl \
    && apt_vacuum

RUN apt-get update && apt-get install -y \
        wget \
        make \
    && apt_vacuum
#        gnupg \

RUN wget -nv https://mirrors.tripadvisor.com/gnu/parallel/parallel-latest.tar.bz2 \
    && tar xvf parallel-latest.tar.bz2 \
    && cd parallel-2*/ \
    && ./configure && make && make install \
    && cd .. \
    && rm -rf parallel-* \
    && mkdir -p /root/.parallel \
    && touch /root/.parallel/will-cite

RUN apt-get update && apt-get install -y \
        moreutils \
    && apt_vacuum

COPY msmtprc_custom.conf /etc/msmtprc_custom
COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/bin/bash","/usr/local/bin/entrypoint.sh"]
