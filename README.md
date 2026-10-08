# logrotate

Centralized log rotation for shared logs. When multiple nodes write to the
same logs, rotation must happen on exactly one node — this image is that
single rotating instance. On startup it generates `/etc/logrotate.conf` from
environment variables, installs its own cron entry, and keeps `crond`
running in the foreground (so the schedule travels with the container, not
with the cluster).

Runs daily, keeps compressed copies next to the originals
(`app.log.1`, `app.log.2.gz`, ...), and uses `copytruncate`, so the
processes writing the logs never need to reopen their files.

## Environment variables

| Variable                | Default       | Description                                                                                                          |
|-------------------------|---------------|----------------------------------------------------------------------------------------------------------------------|
| `LOG_ROTATE_KEEP_DAYS`  | `30`          | Number of rotated files to keep (one per day).                                                                       |
| `LOG_ROTATE_HOUR`       | `1`           | Hour of day (0–23) at which rotation runs.                                                                           |
| `LOG_ROTATE_MAX_SIZE`   | `100M`        | Rotate early if a log exceeds this size (checked at each run). Suffixes: `k`, `M`, `G`; `100MB` also accepted.        |
| `LOG_ROTATE_PATTERN`    | `*.log,*.err` | List of file patterns to rotate. Items are relative to `/var/log/` unless they start with `/`. Comma/space separated. |

Invalid or empty values silently fall back to the defaults.

## Docker stack

Run as a long-lived service on a **single node**, with the shared logs
mounted at `/var/log/`:

```yaml
services:
  rotate:
    image: intellisrc/logrotate:3.24
    environment:
      LOG_ROTATE_KEEP_DAYS: "30"
      LOG_ROTATE_HOUR: "1"
      LOG_ROTATE_MAX_SIZE: "100M"
      LOG_ROTATE_PATTERN: "*.log,*.err"
    volumes:
      - type: bind
        source: "/mnt/logs/"
        target: "/var/log/"
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
```

Or plain docker:

```bash
docker run -d --name logrotate \
  -e LOG_ROTATE_HOUR=3 \
  -v /mnt/logs/:/var/log/ \
  intellisrc/logrotate:3.24
```

## Notes

- `LOG_ROTATE_MAX_SIZE` is only checked when logrotate runs (once a day, at
  `LOG_ROTATE_HOUR`); a size spike between runs is not caught early.
- Avoid a bare `*` pattern: `/var/log/*` also matches already-rotated files
  (`*.log.1`, `*.2.gz`) and would re-rotate them. Use specific patterns
  like `*.log` or `haproxy.*`.
- The state file is `/var/lib/logrotate.status` (container-local). After
  recreating the container, the first cron run may rotate once more than
  expected — harmless.
