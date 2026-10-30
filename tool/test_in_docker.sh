#!/usr/bin/env bash
# Runs `flutter analyze` and the non-UI tests in Docker — no Flutter needed
# here. The screen tests under test/ui are not run.
#
#   tool/test_in_docker.sh
#
# The container is removed when the run ends, pass or fail, and so is the
# network compose made for it; only the pub cache volume is kept, so the next
# run does not download every package again. The exit status is the suite's.
#
# docker-compose.test.yml says why it works the way it does.
set -euo pipefail

cd "$(dirname "$0")/.."
file=docker-compose.test.yml

# `run --rm` removes the container itself. `down` takes the network with it,
# and runs on a failure too, so nothing is left behind either way.
trap 'docker compose -f "$file" down --remove-orphans > /dev/null 2>&1 || true' EXIT

docker compose -f "$file" run --rm test
