#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec clickhouse clickhouse-client --password password -q "
CREATE TABLE IF NOT EXISTS table_to_backup
(
    user_id UInt32,
    message String,
    timestamp DateTime,
    metric Float32
)
ENGINE = MergeTree
PRIMARY KEY (user_id, timestamp);
"

docker compose exec clickhouse clickhouse-client --password password -q "
INSERT INTO table_to_backup (user_id, message, timestamp, metric) VALUES
    (101, 'Hello, ClickHouse!',                                 now(),       -1.0    ),
    (102, 'Insert a lot of rows per batch',                     yesterday(), 1.41421 ),
    (102, 'Sort your data based on your commonly-used queries', today(),     2.718   ),
    (103, 'Granules are the smallest chunks of data read',      now() + 5,   3.14159 );
"