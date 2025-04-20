<!-- omit in toc -->
# Clickhouse backup playground

This repository is used as playground to backup [clickhouse](https://clickhouse.com/) using
[clickhouse-backup from Altinity](https://github.com/Altinity/clickhouse-backup).

- [Requirements](#requirements)
- [Getting started](#getting-started)
- [Perform a manual backup](#perform-a-manual-backup)
- [Restore a backup](#restore-a-backup)
- [License](#license)

## Requirements

- [mise](https://mise.jdx.dev/)
- [docker](https://www.docker.com/)
- [bash](https://www.gnu.org/software/bash/)

## Getting started

First you can launch the stack using:

```bash
$ ./scripts/up.sh
[+] Running 2/2
 ✔ Network clickhouse-backup-playground_default    Created
 ✔ Container clickhouse-backup-playground-minio-1  Healthy
Added `default` successfully.
Bucket created successfully `default/clickhouse-backup`.
mc: Please use 'mc anonymous'
Access Key: root-service-account
Secret Key: root-service-account-secret
Expiration: no-expiry
[+] Running 1/1
 ✔ Container clickhouse-backup-playground-clickhouse-1  Healthy
[+] Copying 1/1
 ✔ clickhouse-backup-playground-clickhouse-1 copy fixtures.sql to clickhouse-backup-playground-clickhouse-1:/fixtures.sql Copied
[+] Running 3/3
 ✔ Container clickhouse-backup-playground-clickhouse-1         Healthy
 ✔ Container clickhouse-backup-playground-minio-1              Running
 ✔ Container clickhouse-backup-playground-clickhouse-backup-1  Started
```

This script will:

1. Launch a [minio](https://min.io/) instance
1. Create a bucket `clickhouse-backup` for backups
1. Launch a [clickhouse](https://clickhouse.com/) databse instance
1. Import [fixtures](./fixtures.sql) into the [clickhouse](https://clickhouse.com/)
   databse instance
1. Launch a [clickhouse-backup](https://github.com/Altinity/clickhouse-backup)
   instance configured to watch clickhouse database and do regular backups

You're now running a clickhouse database with fixtures that is regularly backup
using clickhouse-backup.

By default a backup is performed when clickhouse-backup is launched, you can
list backup using:

```bash
$ docker compose exec clickhouse-backup /bin/clickhouse-backup list remote
...
shard{shard}-full-20250420202211        20/04/2025 20:22:11   remote                                       all:82.52KiB,data:74.28KiB,arch:82.00KiB,obj:529B,meta:0B,rbac:0B,conf:0B   tar, regular
shard{shard}-increment-20250420202711   20/04/2025 20:27:11   remote   +shard{shard}-full-20250420202211   all:485B,data:0B,arch:0B,obj:485B,meta:0B,rbac:0B,conf:0B                   tar, regular
...
```

You can see and edit configuration in [docker-compose.yml](./docker-compose.yml).

## Perform a manual backup

To manually perform a backup you can use:

```bash
$ docker compose exec clickhouse-backup /bin/clickhouse-backup create_remote
...
2025-04-20 20:29:37.463 INF pkg/backup/upload.go:256 > done backup=2025-04-20T20-29-37 duration=60ms object_disk_size=0B operation=upload upload_size=83.20KiB version=2.6.15
2025-04-20 20:29:37.465 INF pkg/storage/general.go:163 > list_duration=1.906533
2025-04-20 20:29:37.465 INF pkg/backup/upload.go:290 > calculate backup list for delete remote duration=2ms operation=RemoveOldBackupsRemote
2025-04-20 20:29:37.465 INF pkg/backup/upload.go:308 > done duration=2ms operation=RemoveOldBackupsRemote
2025-04-20 20:29:37.466 INF pkg/clickhouse/clickhouse.go:336 > clickhouse connection closed
```

Then you can list backup to see the one performed:

```bash
$ docker compose exec clickhouse-backup /bin/clickhouse-backup list remote
...
shard{shard}-full-20250420202211        20/04/2025 20:22:11   remote                                       all:82.52KiB,data:74.28KiB,arch:82.00KiB,obj:529B,meta:0B,rbac:0B,conf:0B   tar, regular
shard{shard}-increment-20250420202711   20/04/2025 20:27:11   remote   +shard{shard}-full-20250420202211   all:485B,data:0B,arch:0B,obj:485B,meta:0B,rbac:0B,conf:0B                   tar, regular
2025-04-20T20-29-37                     20/04/2025 20:29:37   remote                                       all:82.52KiB,data:74.28KiB,arch:82.00KiB,obj:529B,meta:0B,rbac:0B,conf:0B   tar, regular
```

## Restore a backup

First you should probably perform a backup using
[perform a manual backup](#perform-a-manual-backup). When you have a backup
you must edit the database, for exemple we can remove the `fixtures.events`
table using [](./scripts/execute-query-in-clickhouse.sh):

```bash
$ ./scripts/execute-query-in-clickhouse.sh "DROP TABLE fixtures.events SYNC"
```

Then check that table has been deleted:

```bash
$ ./scripts/execute-query-in-clickhouse.sh "SELECT * FROM fixtures.events"
Received exception from server (version 25.3.2):
Code: 60. DB::Exception: Received from localhost:9000. DB::Exception: Unknown table expression identifier 'fixtures.events' in scope SELECT * FROM fixtures.events. (UNKNOWN_TABLE)
(query: SELECT * FROM fixtures.events)
```

If table has been deleted, you can now restore the last backup using:

```bash
$ ./scripts/restore-last-backup.sh
...
2025-04-20 20:36:38.129 INF pkg/backup/restore.go:1456 > done database=fixtures duration=1ms operation=restoreDataRegular progress=1/1 table=events
2025-04-20 20:36:38.130 INF pkg/backup/restore.go:1368 > done backup=shard{shard}-full-20250420203211 duration=27ms operation=restore_data
2025-04-20 20:36:38.130 INF pkg/backup/restore.go:261 > done duration=42ms operation=restore version=2.6.15
2025-04-20 20:36:38.130 INF pkg/clickhouse/clickhouse.go:336 > clickhouse connection closed
```

Now table `fixtures.events` should be restored:

```bash
$ ./scripts/execute-query-in-clickhouse.sh "SELECT COUNT(*) FROM fixtures.events"
5000
```

## License

[MIT](/LICENSE)
