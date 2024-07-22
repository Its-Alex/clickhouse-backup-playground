#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

# Launch and setup minio
docker compose up -d minio --wait
docker compose exec minio sh -c "
    /usr/bin/mc config host add default http://minio:9000 root TVDkAFWNueUy6u;
    /usr/bin/mc mb default/clickhouse-backup;
    /usr/bin/mc policy download default/clickhouse-backup;
    /usr/bin/mc admin user svcacct add default root --access-key \"root-service-account\" \
        --secret-key \"root-service-account-secret\";
    exit 0;
"

# Launch and populate fixtures in ClickHouse
docker compose up -d clickhouse --wait
./scripts/execute-sql-files-in-clickhouse.sh fixtures.sql

# Launch all services
docker compose up -d
