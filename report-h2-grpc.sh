#!/bin/bash

set -eu

cd "${BASH_SOURCE[0]%/*}"
source ./inc.harness.sh

server_id=$(server_create)

export PROXY_INBOUND_ORIG_DST_PORT="$SERVER_GRPC_PORT"
export PROXY_DST_NETWORKS="127.0.0.1/32"
proxy_id=$(proxy_create)

export CLIENT_TARGET_HOST=127.0.0.1:${PROXY_OUTBOUND_PORT}
export MOCK_DST_ENDPOINTS="${CLIENT_TARGET_HOST}=127.0.0.1:$PROXY_INBOUND_PORT#h2"
mock_dst_id=$(mock_dst_create)

start "$server_id" "$proxy_id" "$mock_dst_id"
trap '{ stop "$server_id" "$proxy_id" "$mock_dst_id"; }' EXIT
proxy_await

# Warmup
(TOTAL_REQUESTS=1 client_run_proxy_report "h2-grpc" -grpc)

# Run again with the proper TOTAL_REQUESTS, overwriting the first report.
client_run_proxy_report "h2-grpc" -grpc
