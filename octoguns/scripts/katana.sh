#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

katana --disable-fee --allowed-origins "*"