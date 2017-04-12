FROM alpine
LABEL vendor=DHUniWien

RUN apk update && apk upgrade && apk add --no-cache \
    openssh \
    lighttpd \
    cgit \
    git

# sshd
COPY sshd_config /etc/ssh/
# ssh host keys
RUN ssh-keygen -A

# cgit config
COPY cgitrc /etc/cgitrc

# lighttpd config
COPY lighttpd-cgit.conf /etc/lighttpd/cgit.conf
COPY lighttpd.conf /etc/lighttpd/lighttpd.conf

# dedicated git user
RUN adduser -D -s /usr/bin/git-shell git && \
    passwd -u git && \
    mkdir /home/git/.ssh && \
    chmod 700 /home/git/.ssh && \
    chown -R git. /var/git/ /home/git/.ssh

# add an initial repo
# RUN git init --bare /var/git/sample.git && \
#     chown -R git. sample.git/
#
# clone the above:
# git clone ssh://git@<container's IP>:/var/git/sample.git

WORKDIR /var/git/

COPY run.sh /home/git/run.sh
CMD ["/bin/sh", "/home/git/run.sh"]
