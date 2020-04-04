#!/bin/bash

set -eu

cd "${BASH_SOURCE[0]%/*}"
source ./inc.harness.sh

server_id=$(server_create)
start "$server_id"
trap '{ stop "$server_id"; }' EXIT

client_run_report "baseline" "h1" \
    "http://127.0.0.1:$SERVER_HTTP_PORT"

client_run_report "baseline" "h2-grpc" \
    -grpc "http://127.0.0.1:$SERVER_GRPC_PORT"

