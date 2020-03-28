FROM debian:stable

RUN echo '#!/bin/bash\napt autoremove -y && apt clean -y && rm -rf /var/lib/apt/lists/' > /usr/bin/apt_vacuum \
    && chmod +x /usr/bin/apt_vacuum

RUN apt-get update && apt-get install -y \
        mailutils \
        ssmtp \
    && apt_vacuum

COPY ssmtp_custom.conf /etc/ssmtp/ssmtp_custom.conf
COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/bin/bash","/usr/local/bin/entrypoint.sh"]
