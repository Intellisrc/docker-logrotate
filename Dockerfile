FROM intellisrc/alpine:3.17

# Will look for: /etc/restic/exclude.lst
VOLUME ["/mnt/backup", "/etc/restic"]
# --------------- SYSTEM ------------------
RUN apk add --update --no-cache logrotate

COPY setup/logrotate.conf /etc/logrotate.d/general
RUN chmod 644 /etc/logrotate.d/general

CMD [ "" ]
