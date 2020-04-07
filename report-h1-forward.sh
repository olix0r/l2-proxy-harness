#!/bin/bash

set -eu

cd "${BASH_SOURCE[0]%/*}"
source ./inc.harness.sh

server_id=$(server_create)

export PROXY_DST_SUFFIXES=""
proxy_id=$(proxy_create)

export CLIENT_TARGET_HOST=h1-forward.test.example.com
mock_dst_id=$(mock_dst_create)

start "$server_id" "$proxy_id" "$mock_dst_id"
trap '{ stop "$server_id" "$proxy_id" "$mock_dst_id"; }' EXIT
proxy_await

# Warmup
curl -so /dev/null \
    -H "Host: $CLIENT_TARGET_HOST" \
    "http://127.0.0.1:$PROXY_OUTBOUND_PORT"

client_run_proxy_report "h1-forward"

proxy_metrics > "./reports/${RUN_ID}-h1-forward.metrics"
