#!/bin/bash

set -eu

cd "${BASH_SOURCE[0]%/*}"
source ./inc.harness.sh

CLIENT_TARGET_HOST="127.0.0.1:${PROXY_OUTBOUND_PORT}"
MOCK_DST_ENDPOINTS="${CLIENT_TARGET_HOST}=127.0.0.1:$PROXY_INBOUND_PORT#h2#$PROXY_IDENTITY_LOCAL_NAME"
PROXY_DST_NETWORKS="127.0.0.1/32"
PROXY_INBOUND_ORIG_DST_PORT="$SERVER_GRPC_PORT"

server_id=$(server_create)
mock_dst_id=$(mock_dst_create)
proxy_id=$(proxy_create)
start "$server_id" "$proxy_id" "$mock_dst_id"
trap '{ stop "$server_id" "$proxy_id" "$mock_dst_id"; }' EXIT
proxy_await

CONCURRENCY="${CONCURRENCY:-1}"

(TOTAL_REQUESTS=1 client_run_proxy_report "x${CONCURRENCY}.h2" -grpc)
client_run_proxy_report "x${CONCURRENCY}.h2" -grpc -quiet
