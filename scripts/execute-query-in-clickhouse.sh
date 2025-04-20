#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec clickhouse clickhouse-client -u default --password password -q "$1"
