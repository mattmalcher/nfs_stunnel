# nfs_stunnel
Attempt to create a dockerised NFS server using stunnel for encryption in transit.

# stunnel?
Stunnel is kind of a proxy server you can use to wrap TLS encryption around services which dont natively support it. 

# systemd...
Docker containers are designed to host a single service, so they dont typically have an init service like systemd running inside them.

BUT we want to use systemd to start the NFS server & stunnel services.

It is definitely possible to run multiple services inside a container (Gitlab does it).

Options are:

- Manage services without systemd. This is what `nfs-server-alpine` does. See [nfsd.sh](https://github.com/sjiveson/nfs-server-alpine/blob/master/nfsd.sh)) Above my current skill level.
- Get systemd running inside the container. Something like: https://github.com/damianoneill/docker-centos-systemd
- Emulate systemd. Something like: https://github.com/gdraheim/docker-systemctl-replacement


Running systemd seems like the most straightforward option, even if it does require additional container priveleges. 

## Alternatives
Share NFS over ssh - not really what it was meant for
Use EFS or equivalent services which already offer encryption - £££

# Refs

## A dockerised NFS Server (no stunnel)
https://github.com/sjiveson/nfs-server-alpine
https://hub.docker.com/r/itsthenetwork/nfs-server-alpine/tags

## Setting up stunnel for NFS (not in docker)
https://www.linuxjournal.com/content/encrypting-nfsv4-stunnel-tls

## stunnel
https://www.stunnel.org/
https://en.wikipedia.org/wiki/Stunnel