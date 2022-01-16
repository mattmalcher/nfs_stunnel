# NFS Over Stunnel

## ----------------------------------------------------------------------
## This makefile automates the steps to set up an stunneled NFS server 
## in a docker container.
## ----------------------------------------------------------------------

help:     ## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

build: ## use compose file to build and tag service
	docker-compose build 

run: ## use compose file to run service in detached mode with a consistent name. Delete on exit and respect port mappings.
	docker-compose run --rm --name rocky_nfs_run --service-ports -d rocky_nfs

exec: ## drop into the container for debugging
	docker exec -it rocky_nfs_run bash

stop: ## stop container and removes containers, networks, volumes, and images
	docker-compose down
	rm -f nfs_share/*

mount_plain: # mounts the non-stunneled NFS server (need to map 2050)
	mkdir -p ~/mnt/plain
	sudo mount -o port=2050 -o vers=4.2 -t nfs 127.0.0.1:/ ~/mnt/plain/

unmount_plain:
	umount ~/mnt/plain
	rmdir -p ~/mnt/plain

gen_key: ## generate a key/certificate to use for the connection
	openssl req -newkey rsa:4096 -x509 -days 3650 -nodes \
	-out nfs-tls.pem \
	-keyout nfs-tls.pem \
	-subj "/C=GB/ST=London/O=MART/OU=DEV/CN=exampledomain.com"

scp_key: ## template for command to copy the key file from the server to the client. 
	scp nfs-tls.pem user@host:/folder

setup_client:  ## configure a client machine to use stunnel
	# copy config files to relevant places
	sudo cp client/3d-nfsd.socket /etc/systemd/system
	sudo cp client/3d-nfsd@.service /etc/systemd/system
	sudo cp client/3d-nfsd.conf /etc/stunnel
	sudo cp nfs-tls.pem /etc/stunnel

	# make folder for logs
	sudo mkdir -p /var/empty/stunnel

	# register the config with systemd
	sudo systemctl enable 3d-nfsd.socket
	sudo systemctl start 3d-nfsd.socket

	# define share in fstab
	sudo echo "localhost:/ /home/share nfs noauto,vers=4.2,proto=tcp,port=2323 0 0" >> /etc/fstab

	# not 100% sure this is needed, want changes in services and fstab to be picked up
	sudo systemctl daemon-reload

mount_stunnel: ## after a client has been set up
	sudo mkdir /home/share
	sudo mount /home/share

unmount_stunnel:
	sudo umount /home/share
	sudo rmdir -p /home/share

add_firewall_exemption: ## allows the server to receive incoming tcp connections on the port used for stunnel
	sudo iptables -w -I INPUT -p tcp --dport 2363 --syn -j ACCEPT