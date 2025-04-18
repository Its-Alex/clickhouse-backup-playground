#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

LATEST_BACKUP=$(docker compose exec clickhouse-backup /bin/clickhouse-backup list remote latest)
docker compose exec clickhouse-backup /bin/clickhouse-backup restore_remote --drop "$LATEST_BACKUP"
