# nfs_stunnel
Proof of concept dockerised NFS server using stunnel for encryption in transit.

# stunnel?
Stunnel is kind of a proxy server you can use to wrap TLS encryption around services which dont natively support it (like NFS).

# systemd...
Docker containers are designed to host a single service, so they dont typically have an init service like systemd running inside them.

BUT we want to use systemd to start the NFS server & stunnel services.

It is definitely possible to run multiple services inside a container (Gitlab does it).

Options are:

- Manage services without systemd. This is what `nfs-server-alpine` does. See [nfsd.sh](https://github.com/sjiveson/nfs-server-alpine/blob/master/nfsd.sh)) Above my current skill level.
- Get systemd running inside the container. Something like: https://github.com/damianoneill/docker-centos-systemd
- Emulate systemd. Something like: https://github.com/gdraheim/docker-systemctl-replacement


Running systemd seems like the most straightforward option, even if it does require additional container priveleges. 

# TODO's
Have gotten this all to work, but the following improvements are in order:

- The client setup in `client/3d-nfsd.conf` needs the host name / ip changing. Also, we probably want to use the commented out options for centos/rocky clients.
- The mount paths are probably not what we want
- The key file should probably have an actual domain in it
- If you can ssh to the server, then you can access the non stunnelled NFS share, but im not sure that really matters for the intended use case.
- Never figured out why I couldnt mount NFS server in container via localhost, only from another machine.
- Remove the 192.168.0.0/24 export from `/etc/exports` we only want the nfs share to be available over stunnel (which grabs it from localhost), not directly from other machines on the network (though this could be useful for development?)
- can potentially remove nc from container now debugged.
- really needs some validation that its working properly wrt permissions etc.

## Alternatives
Share NFS over ssh - not really what it was meant for.
Use EFS or equivalent services which already offer encryption - £££ for performance we need.

# Refs

## A dockerised NFS Server (no stunnel)
https://github.com/sjiveson/nfs-server-alpine
https://hub.docker.com/r/itsthenetwork/nfs-server-alpine/tags

## Setting up stunnel for NFS (not in docker)
https://www.linuxjournal.com/content/encrypting-nfsv4-stunnel-tls

## stunnel
https://www.stunnel.org/
https://en.wikipedia.org/wiki/Stunnel