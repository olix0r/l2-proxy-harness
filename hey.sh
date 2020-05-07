#!/bin/bash

set -eu

cd "${BASH_SOURCE[0]%/*}"
source ./inc.harness.sh

server_id=$(server_create)

#export PROXY_IMAGE=olix0r/l2-proxy:v2.95.0-mock-orig-dst
proxy_id=$(proxy_create)

export CLIENT_TARGET_HOST=h1.test.example.com
export MOCK_DST_ENDPOINTS="${CLIENT_TARGET_HOST}:80=127.0.0.1:$PROXY_INBOUND_PORT"
mock_dst_id=$(mock_dst_create)

start "$server_id" "$proxy_id" "$mock_dst_id"
trap '{ stop "$server_id" "$proxy_id" "$mock_dst_id"; }' EXIT
proxy_await

echo ":;" hey -z 10s -q 500 -c 1000 -host "$CLIENT_TARGET_HOST" "http://127.0.0.1:$PROXY_OUTBOUND_PORT"
hey -z 10s -q 500 -c 1000 -host "$CLIENT_TARGET_HOST" "http://127.0.0.1:$PROXY_OUTBOUND_PORT"

mkdir -p target
proxy_metrics >target/hey.metrics
docker logs "$proxy_id" >target/hey.log


