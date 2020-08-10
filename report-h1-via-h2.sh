#!/bin/bash

set -eu

cd "${BASH_SOURCE[0]%/*}"
source ./inc.harness.sh

server_id=$(server_create)
proxy_id=$(proxy_create)

export CLIENT_TARGET_HOST=h1-via-h2.test.example.com
export MOCK_DST_ENDPOINTS="${CLIENT_TARGET_HOST}:80=127.0.0.1:$PROXY_INBOUND_PORT#h2#foo.ns1.serviceaccount.identity.linkerd.cluster.local"
mock_dst_id=$(mock_dst_create)

start "$server_id" "$proxy_id" "$mock_dst_id"
trap '{ stop "$server_id" "$proxy_id" "$mock_dst_id"; }' EXIT
proxy_await

# Warmup
curl -so /dev/null \
    -H "Host: $CLIENT_TARGET_HOST" \
    "http://127.0.0.1:$PROXY_OUTBOUND_PORT"

client_run_proxy_report "h1-via-h2"
