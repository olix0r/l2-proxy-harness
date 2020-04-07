#!/bin/bash

set -eu

cd "${BASH_SOURCE[0]%/*}"
source ./inc.harness.sh

server_id=$(server_create)

export PROXY_INBOUND_ORIG_DST_PORT="$SERVER_GRPC_PORT"
export PROXY_DST_SUFFIXES=""
export PROXY_DST_NETWORKS=""
proxy_id=$(proxy_create)

mock_dst_id=$(mock_dst_create)

start "$server_id" "$proxy_id" "$mock_dst_id"
trap '{ stop "$server_id" "$proxy_id" "$mock_dst_id"; }' EXIT
proxy_await

export CLIENT_TARGET_HOST=h2-grpc-forward.test.example.com

# Warmup
(TOTAL_REQUESTS=1 client_run_proxy_report "h2-grpc-forward" -grpc)

# Run again with the proper TOTAL_REQUESTS, overwriting the first report.
client_run_proxy_report "h2-grpc-forward" -grpc
