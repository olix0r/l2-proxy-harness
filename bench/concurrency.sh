#!/bin/sh

set -eu

RUN_ID="${RUN_ID:-concurrency}"
REPORTS_DIR="${REPORTS_DIR:-.}"
TOTAL_REQUESTS="${TOTAL_REQUESTS:-100000}"
REQUESTS_PER_SEC="${REQUESTS_PER_SEC:-10000}"
CONCURRENCIES="${CONCURRENCIES:-001 010 050 100 300}"
SERVICE_NAME="${SERVICE_NAME:-server}"

for x in $CONCURRENCIES ; do
  fortio curl "http://${SERVICE_NAME}:8080"
  fortio load \
    -labels "{\"run\":\"$RUN_ID\",\"kind\":\"proxy\",\"name\":\"h1-x${x}\"}" \
    -json "/reports/proxy-h1-x${x}" \
    "http://${SERVICE_NAME}:8080"
  sleep 5
done

fortio grpcping "${SERVICE_NAME}:8079"
for x in $CONCURRENCIES ; do
  fortio load \
    -labels "{\"run\":\"$RUN_ID\",\"kind\":\"proxy\",\"name\":\"h2-x${x}\"}" \
    -json "/reports/proxy-h2-x${x}" \
     "${SERVICE_NAME}:8079"
  sleep 5
done

# Combine all of the individual reports into an array.
jq -s '.' "$REPORTS_DIR/$RUN_ID/"*.json \
  > "$REPORTS_DIR/$RUN_ID.json"
