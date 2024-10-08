#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

sozo migrate plan

sozo migrate apply --wait 

export WORLD_ADDRESS=$(cat ./manifests/dev/deployment/manifest.json | jq -r '.world.address')

sozo execute mapmaker default_map --world $WORLD_ADDRESS 

