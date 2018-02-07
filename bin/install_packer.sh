#!/usr/bin/env bash
set -o verbose
set -o errexit
set -o pipefail
set -o nounset

EXECUTABLES_DIR=./bin

PACKER_VERSION="1.1.3"
PACKER_SHA256SUM="b7982986992190ae50ab2feb310cb003a2ec9c5dcba19aa8b1ebb0d120e8686f"


PACKER_VERSION=${PACKER_VERSION:?"ERROR: PACKER_VERSION not set"}
PACKER_SHA256SUM=${PACKER_SHA256SUM:?"ERROR: PACKER_SHA256SUM not set"}

curl -L --output /tmp/packer-${PACKER_VERSION}.zip \
     https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip

echo "${PACKER_SHA256SUM}  /tmp/packer-${PACKER_VERSION}.zip" > /tmp/packer_SHA256
sha256sum -c /tmp/packer_SHA256

unzip -o /tmp/packer-${PACKER_VERSION}.zip -d ${EXECUTABLES_DIR}
chmod +x ${EXECUTABLES_DIR}/packer

${EXECUTABLES_DIR}/packer version
