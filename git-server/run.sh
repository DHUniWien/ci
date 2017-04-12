#!/bin/sh

/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf

# will stay in foreground
/usr/sbin/sshd -D
