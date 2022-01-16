FROM rockylinux/rockylinux:8.5

# install packages required
RUN yum -y install \
    nfs-utils \
    stunnel \
    && \
    yum -y clean all && \
    rm -rf /var/cache

# Prepare for using systemd. 
# From https://github.com/damianoneill/docker-centos-systemd/blob/master/Dockerfile
# and https://github.com/robertdebock/docker-rockylinux-systemd/blob/master/Dockerfile
# requires :
#   entrypoint: /sbin/init, 
#   privileged: true
#   volumes: 
#     - /sys/fs/cgroup:/sys/fs/cgroup:ro
ENV container=docker

RUN cd /lib/systemd/system/sysinit.target.wants/ ; \
    for i in * ; do [ $i = systemd-tmpfiles-setup.service ] || rm -f $i ; done ; \
    rm -f /lib/systemd/system/multi-user.target.wants/* ; \
    rm -f /etc/systemd/system/*.wants/* ; \
    rm -f /lib/systemd/system/local-fs.target.wants/* ; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* ; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* ; \
    rm -f /lib/systemd/system/basic.target.wants/* ; \
    rm -f /lib/systemd/system/anaconda.target.wants/*

VOLUME ["/sys/fs/cgroup"]

# make nfs serviced run at startup. 
# Should also start required services such as rpcbind & nfs-idmapd
RUN systemctl enable nfs-server rpcbind

# Allow clear text NFS on 2049 for testing (comment out for prod)
#RUN iptables -w -I INPUT -p tcp --dport 2049 --syn -j ACCEPT

# # set up share directory
RUN mkdir /home/share && \
    chmod 777 /home/share && \
    cp /etc/services /etc/nsswitch.conf /etc/hosts /home/share

# start systemd - required!
CMD ["/usr/sbin/init"]