FROM debian:buster
COPY --from=fortio/fortio:latest /usr/bin/fortio /usr/local/bin/fortio
RUN apt-get update && \
    apt-get install -y netcat curl openssl jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY concurrency.sh /usr/lib/linkerd-bench/concurrency.sh
