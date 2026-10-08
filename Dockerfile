FROM intellisrc/alpine:3.24

# Centralized log rotation for shared logs: run exactly ONE instance
# (single node) per set of shared logs. See setup/run for details.
RUN apk add --update --no-cache logrotate

# Packaged default; setup/run regenerates it from env vars at startup.
COPY setup/logrotate.conf /etc/logrotate.conf
RUN chmod 644 /etc/logrotate.conf # logrotate rejects group-writable configs

ENV LOG_ROTATE_KEEP_DAYS=30
ENV LOG_ROTATE_HOUR=1
ENV LOG_ROTATE_MAX_SIZE=100M
ENV LOG_ROTATE_PATTERN="*.log,*.err"

COPY setup/run /home/run
RUN chmod +x /home/run
WORKDIR /home
ENTRYPOINT [ "./run" ]
