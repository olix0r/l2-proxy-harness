  #!/bin/bash

set -eu

cd "${BASH_SOURCE[0]%/*}"
source ./inc.harness.sh

CONCURRENCY="${CONCURRENCY:-1}"

server_id=$(server_create)
start "$server_id"
trap '{ stop "$server_id"; }' EXIT

client_run_report "baseline" "x${CONCURRENCY}.h1" -quiet \
    "http://127.0.0.1:$SERVER_HTTP_PORT"

client_run_report "baseline" "x${CONCURRENCY}.h2" -grpc -quiet \
    "127.0.0.1:$SERVER_GRPC_PORT"

