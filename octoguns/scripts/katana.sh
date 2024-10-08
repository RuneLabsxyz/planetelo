#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

katana --disable-fee --invoke-max-steps 420000000 --allowed-origins "*"