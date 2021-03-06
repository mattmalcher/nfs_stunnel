FROM rockylinux/rockylinux:8.5

# install packages required
RUN yum -y install \
    nfs-utils \
    stunnel \
    nc \
    net-tools \
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

# # set up share directory
RUN mkdir /home/share && \
    chmod 777 /home/share

# add share directory to exported folders
RUN echo "/home/share/ 192.168.0.0/24(fsid=0,rw,sync)" >> /etc/exports && \
    echo "/home/share/ 127.0.0.1(fsid=0,rw,sync,insecure)" >> /etc/exports


# Add cert
COPY nfs-tls.pem /etc/stunnel

# inetd-style socket activation unit on port 2363 to launch stunnel with a timeout of ten minutes
COPY MC-nfsd.socket /etc/systemd/system
#socket to launch stunnel
COPY MC-nfsd@.service /etc/systemd/system
#stunnel control file for the NFS server
COPY MC-nfsd.conf /etc/stunnel

RUN systemctl enable MC-nfsd.socket

# chroot() directory where stunnel will drop privileges
RUN mkdir /var/empty/stunnel

# start systemd - required!
CMD ["/usr/sbin/init"]