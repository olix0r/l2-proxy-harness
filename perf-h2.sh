#!/bin/bash

set -eu

cd "${BASH_SOURCE[0]%/*}"
source ./inc.harness.sh

CLIENT_TARGET_HOST="127.0.0.1:${PROXY_OUTBOUND_PORT}"
MOCK_DST_ENDPOINTS="${CLIENT_TARGET_HOST}=127.0.0.1:$PROXY_INBOUND_PORT#h2"
PROXY_DST_NETWORKS="127.0.0.1/32"
PROXY_INBOUND_ORIG_DST_PORT="$SERVER_GRPC_PORT"
PROXY_IMAGE="${PROXY_IMAGE:-olix0r/l2-proxy:buffer-cache.mod}"

export TOTAL_REQUESTS="${TOTAL_REQUESTS:-1000}"
export REQUESTS_PER_SEC="${REQUESTS_PER_SEC:-1000}"
export SERVER_CPUS="${SERVER_CPUS:-1}"
export CLIENT_CPUS="${CLIENT_CPUS:-1}"
export PROXY_CPUS="${PROXY_CPUS:-1}"
export CONCURRENCY="${CONCURRENCY:-300}"


server_id=$(server_create)
mock_dst_id=$(mock_dst_create)
proxy_id=$(proxy_create)
start "$server_id" "$proxy_id" "$mock_dst_id"
trap '{ stop "$server_id" "$proxy_id" "$mock_dst_id"; }' EXIT
proxy_await

(TOTAL_REQUESTS=1 client_run_proxy_report "x${CONCURRENCY}.h2" -grpc -quiet)

proxy_pid="$(pgrep -f linkerd2-proxy)"
sudo perf record -g -p "$proxy_pid" &

client_run_proxy_report "x${CONCURRENCY}.h2" -grpc
