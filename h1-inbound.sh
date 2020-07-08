#!/bin/bash

set -eu

cd "${BASH_SOURCE[0]%/*}"
source ./inc.harness.sh

CLIENT_TARGET_HOST=h1.test.example.com:8080
PROXY_INBOUND_ORIG_DST_PORT="$SERVER_HTTP_PORT"

server_id=$(server_create)
mock_dst_id=$(mock_dst_create)
proxy_id=$(proxy_create)
start "$server_id" "$proxy_id" "$mock_dst_id"
trap '{ stop "$server_id" "$proxy_id" "$mock_dst_id"; }' EXIT
proxy_await

CONCURRENCY="${CONCURRENCY:-1}"

# Warmup
curl -so /dev/null \
    -H "Host: $CLIENT_TARGET_HOST" \
    "http://127.0.0.1:$PROXY_INBOUND_PORT"
client_run_report proxy  "x${CONCURRENCY}.h1" -quiet \
    -H "Host: $CLIENT_TARGET_HOST" \
    "http://127.0.0.1:$PROXY_INBOUND_PORT"
