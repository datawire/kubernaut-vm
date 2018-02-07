#!/usr/bin/env bash
set -o verbose
set -o errexit
set -o pipefail
set -o nounset

EXECUTABLES_DIR=./bin

TERRAFORM_VERSION="0.11.3"
TERRAFORM_SHA256SUM="6b8a7b83954597d36bbed23913dd51bc253906c612a070a21db373eab71b277b"

curl -L --output /tmp/terraform-${TERRAFORM_VERSION}.zip \
     https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

echo "${TERRAFORM_SHA256SUM}  /tmp/terraform-${TERRAFORM_VERSION}.zip" > /tmp/terraform_SHA256
sha256sum -c /tmp/terraform_SHA256

unzip -o /tmp/terraform-${TERRAFORM_VERSION}.zip -d ${EXECUTABLES_DIR}
chmod +x ${EXECUTABLES_DIR}/terraform

${EXECUTABLES_DIR}/terraform version
