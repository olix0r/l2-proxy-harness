# linkerd2 proxy test harness

## Requires

* `bash`;
* `curl`;
* `docker` client;
* and `jq`.

## Configuration

The `PROXY_IMAGE` environment variable may be set with a reference to a proxy built with the
`mock-orig-dst` feature flag. The `olix0r/l2-proxy:harness.v1` image is used by default.

The `MOCK_DST_IMAGE` environment variable may be set with a reference to mock dst controller. The
`olix0r/l2-mock-dst:v1` image is used by default.

The `RUN_ID` environment variable may be set to name `run` used in reports, otherwise a random ID
is assigned.

The `TOTAL_REQUESTS` `REQUESTS_PER_SEC` and `CONCURRENCY` environment variables may be set to control the load test used

## Running

```sh
./gen-reports
```

Reports are accumulated into `./reports/reports.json`.
