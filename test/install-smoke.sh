#!/usr/bin/env bash
# Install smoke test: run ./install --yes as a new sudo user in a clean
# container, then check the result (test/install-smoke-run.sh). Needs docker.
# Usage: test/install-smoke.sh [base-image]   (default: ubuntu:24.04)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

image="${1:-ubuntu:24.04}"
tag="dotfiles-install-smoke:${image//[:\/]/-}"

docker build --build-arg "BASE_IMAGE=$image" -f test/install-smoke.Dockerfile -t "$tag" .
docker run --rm "$tag" < /dev/null
