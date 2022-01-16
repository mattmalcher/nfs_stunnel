# NFS Over Stunnel

## ----------------------------------------------------------------------
## This makefile automates the steps to set up an stunneled NFS server 
## in a docker container.
## ----------------------------------------------------------------------

help:     ## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

gen_key: ## generate a key/certificate to use for the connection
	openssl req -newkey rsa:4096 -x509 -days 3650 -nodes \
	-out nfs-tls.pem \
	-keyout nfs-tls.pem \
	-subj "/C=GB/ST=London/O=MART/OU=DEV/CN=exampledomain.com"

build:
	docker-compose build 

run: 
	docker-compose run --rm --name rocky_nfs_run -d rocky_nfs

exec:
	docker exec -it rocky_nfs_run bash

stop:
	docker-compose down
	rm -f nfs_share/*