#!/usr/bin/env bash
set -o verbose
set -o errexit
set -o pipefail
set -o nounset

export PATH=bin/:$PATH

variables_file="packer_variables.json"
template_file="packer.json"

cat << EOF > packer_variables.json
{
  "build_number"     : "${TRAVIS_BUILD_NUMBER}",
  "builder"          : "travis",
  "commit"           : "${COMMIT_HASH}",
  "forge_deregister" : "false"
}
EOF

packer version

packer validate -var-file=${variables_file} ${template_file}
packer build -machine-readable -var-file=${variables_file} ${template_file} | tee packer.log
