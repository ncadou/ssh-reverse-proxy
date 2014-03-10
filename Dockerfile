# Tunneled reverse proxy using SSH and nginx.

FROM hansd/nginx
MAINTAINER Nicolas Cadou <ncadou@cadou.ca>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y autossh supervisor && \
    apt-get clean

RUN mkdir /root/.ssh/
ADD ssh-config /root/.ssh/config
RUN chown -R root:root /root/.ssh && \
    chmod 700 /root/.ssh

ADD supervisord.conf /etc/supervisor/
ADD init /usr/local/sbin/init.ssh-reverse-proxy

ENTRYPOINT ["/usr/local/sbin/init.ssh-reverse-proxy"]
