#!/usr/bin/env bash
set -o verbose
set -o errexit
set -o pipefail

KUBERNAUT_AGENT_PLATFORM="linux/x86_64"
KUBERNAUT_AGENT_VERSION="${KUBERNAUT_AGENT_VERSION:?Environment variable 'KUBERNAUT_AGENT_VERSION' not set}"

DOWNLOAD_URL="https://s3.amazonaws.com/datawire-static-files/kubernaut-agent/${KUBERNAUT_AGENT_VERSION}/${KUBERNAUT_AGENT_PLATFORM}/kubernaut-agent"

echo "Downloading Kubernaut..."
echo "URL: $DOWNLOAD_URL"

curl -L \
    --output /usr/local/bin/kubernaut-agent \
    ${DOWNLOAD_URL}

chmod +x /usr/local/bin/kubernaut-agent
