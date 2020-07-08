#!/bin/bash

set -eu

cd "${BASH_SOURCE[0]%/*}"
source ./inc.harness.sh

CLIENT_TARGET_HOST=h1.test.example.com:8080
MOCK_DST_ENDPOINTS="${CLIENT_TARGET_HOST}=127.0.0.1:$SERVER_HTTP_PORT"
PROXY_DST_NETWORKS="127.0.0.1/32"
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
    "http://127.0.0.1:$PROXY_OUTBOUND_PORT"
client_run_proxy_report "x${CONCURRENCY}.h1" -quiet

rss=$(proxy_metrics | awk '$1 ~ /^process_resident_memory_bytes/ { printf("%.01dMB\n", $1 / 1024.0 / 1024.0); }')
echo "#RSS $rss"
