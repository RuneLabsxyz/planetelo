set -euo pipefail
pushd $(dirname "$0")/..

export WORLD_ADDRESS=$(cat ./manifests/dev/deployment/manifest.json | jq -r '.world.address')

torii --world $WORLD_ADDRESS --allowed-origins "*"
