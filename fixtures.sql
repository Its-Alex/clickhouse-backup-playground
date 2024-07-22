CREATE DATABASE IF NOT EXISTS fixtures;

CREATE TABLE IF NOT EXISTS fixtures.events (
    event_date Date,
    event_time DateTime,
    user_id UInt32,
    event_type String,
    value Float64
) ENGINE = MergeTree()
ORDER BY (event_date, user_id);

INSERT INTO fixtures.events
    SELECT
        toDate('2023-01-01') + rand() % 365 as event_date,
        toDateTime(event_date) + rand() % 86400 as event_time,
        rand() % 10000 as user_id,
        ['click', 'view', 'purchase', 'login', 'logout'][rand() % 5 + 1] as event_type,
        rand() % 1000 + rand() as value
    FROM system.numbers
    LIMIT 5000;
