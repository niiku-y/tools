#!/bin/bash
# make_docker_certs.sh
#
# Usage)
#   ./make_docker_certs.sh

# sample
CERTED_DOMAIN="myhostname"
PORT=5001
CERTS_DIR="/etc/docker/certs.d/${CERTED_DOMAIN}:${PORT}"

echo "create *.crt ..."
sudo mkdir  ./certs
sudo openssl req -newkey rsa:4096 -nodes -sha256 \
  -keyout ./certs/domain_${CERTED_DOMAIN}.key \
  -x509 -days 365 -out ./certs/domain_${CERTED_DOMAIN}.crt
sudo ls -l ./certs

echo "copy *.crt to registry client ..."
sudo mkdir -p ${CERTS_DIR}
sudo cp ./certs/domain_${CERTED_DOMAIN}.crt ${CERTS_DIR}/ca.crt
sudo chown root:root ${CERTS_DIR}/ca.crt
sudo ls -l ${CERTS_DIR}


