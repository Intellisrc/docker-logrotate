# logrotate

Perform log rotation of logs. When using multiple nodes, it is important
to execute logrotate only once or it won't work as expected. This is a 
centralized way to rotate logs.

## Docker stack

Using `crazymax/swarm-cronjob` to execute cron jobs.

```yaml
services:
  rotate:
    image: intellisrc/logrotate:3.17
    volumes:
      - type: bind
        source: "/mnt/logs/"
        target: "/var/log/"
    deploy:
      mode: replicated
      replicas: 0
      restart_policy:
        condition: none
      labels:
        - "swarm.cronjob.enable=true"
        - "swarm.cronjob.schedule=0 0 * * *"
        - "swarm.cronjob.skip-running=true"
      placement:
        constraints:
          - node.role == manager
```
