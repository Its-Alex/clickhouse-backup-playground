#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

FILENAME=$(basename "$1")
docker compose cp "$1" "clickhouse:/$FILENAME"
docker compose exec clickhouse clickhouse-client -u default --password password --queries-file "/$FILENAME"
