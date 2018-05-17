#!/usr/bin/env bash
set -o verbose
set -o errexit
set -o pipefail
set -o nounset

EXECUTABLES_DIR=./bin

PACKER_VERSION="1.2.3"
PACKER_SHA256SUM="822fe76c2dfe699f187ef8c44537d10453a1545db620e40b345cf6991a690f7d"


PACKER_VERSION=${PACKER_VERSION:?"ERROR: PACKER_VERSION not set"}
PACKER_SHA256SUM=${PACKER_SHA256SUM:?"ERROR: PACKER_SHA256SUM not set"}

curl -L --output /tmp/packer-${PACKER_VERSION}.zip \
     https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip

echo "${PACKER_SHA256SUM}  /tmp/packer-${PACKER_VERSION}.zip" > /tmp/packer_SHA256
sha256sum -c /tmp/packer_SHA256

unzip -o /tmp/packer-${PACKER_VERSION}.zip -d ${EXECUTABLES_DIR}
chmod +x ${EXECUTABLES_DIR}/packer

${EXECUTABLES_DIR}/packer version
