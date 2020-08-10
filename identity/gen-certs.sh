#!/bin/bash
#
# Requires:
# go get -u github.com/cloudflare/cfssl/cmd/cfssl
# go get -u github.com/cloudflare/cfssl/cmd/cfssljson
#
set -euox pipefail

ca() {
  name=$1
  filename=$2

  echo "{\"names\":[{\"CN\": \"${name}\",\"OU\":\"None\"}], \"ca\": {\"expiry\": \"87600h\"}}" \
    | cfssl genkey -initca - \
    | cfssljson -bare "${filename}"

  rm "${filename}.csr"
}

ee() {
  ca_name=$1
  ee_name=$2
  ee_ns=$3
  cp_ns=$4

  hostname="${ee_name}.${ee_ns}.serviceaccount.identity.${cp_ns}.cluster.local"

  ee="${ee_name}-${ee_ns}-${ca_name}"
  echo '{}' \
    | cfssl gencert -ca "${ca_name}.pem" -ca-key "${ca_name}-key.pem" -hostname "${hostname}" -config=ca-config.json - \
    | cfssljson -bare "${ee}"
  mkdir -p "${hostname}"

  openssl pkcs8 -topk8 -nocrypt -inform pem -outform der \
    -in "${ee}-key.pem" \
    -out "${hostname}/key.p8"
  rm "${ee}-key.pem"

  openssl req -outform DER \
    -in "${ee}.csr" \
    -out "${hostname}/csr.der"
  rm "${ee}.csr"

  mv "${ee}.pem" "${hostname}/crt.pem"

  rm "${ca_name}-key.pem"
}

ca "Cluster-local CA 1" ca
ee ca foo ns1 linkerd
