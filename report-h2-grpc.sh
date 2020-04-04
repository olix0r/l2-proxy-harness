#!/bin/bash

set -eu

cd "${BASH_SOURCE[0]%/*}"
source ./inc.harness.sh

server_id=$(server_create)

export PROXY_LOG="linkerd=debug,warn"
export PROXY_INBOUND_ORIG_DST_PORT="$SERVER_GRPC_PORT"
proxy_id=$(proxy_create)

export CLIENT_TARGET_HOST=h2-grpc.test.example.com
export MOCK_DST_ENDPOINTS="${CLIENT_TARGET_HOST}:80=127.0.0.1:$PROXY_INBOUND_PORT#h2"
mock_dst_id=$(mock_dst_create)

start "$server_id" "$proxy_id" "$mock_dst_id"
trap '{ stop "$server_id" "$proxy_id" "$mock_dst_id"; }' EXIT
proxy_await

# Warmup
(TOTAL_REQUESTS=1 client_run_proxy_report "h2-grpc")

# Run again with the proper TOTAL_REQUESTS, overwriting the first report.
client_run_proxy_report "h2-grpc"
