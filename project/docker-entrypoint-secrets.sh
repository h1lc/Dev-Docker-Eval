#!/bin/sh
set -e

if [ -n "$POSTGRES_USER_FILE" ] && [ -f "$POSTGRES_USER_FILE" ]; then
  POSTGRES_USER=$(cat "$POSTGRES_USER_FILE" 2>/dev/null | head -n 1 | tr -d '\n\r\t ' || echo "")
  if [ -n "$POSTGRES_USER" ]; then
    export POSTGRES_USER
  fi
  unset POSTGRES_USER_FILE
fi

if [ -n "$POSTGRES_DB_FILE" ] && [ -f "$POSTGRES_DB_FILE" ]; then
  POSTGRES_DB=$(cat "$POSTGRES_DB_FILE" 2>/dev/null | head -n 1 | tr -d '\n\r\t ' || echo "")
  if [ -n "$POSTGRES_DB" ]; then
    export POSTGRES_DB
  fi
  unset POSTGRES_DB_FILE
fi

if [ -f "/usr/local/bin/docker-entrypoint.sh" ]; then
  exec /usr/local/bin/docker-entrypoint.sh "$@"
elif [ -f "/docker-entrypoint.sh" ]; then
  exec /docker-entrypoint.sh "$@"
else
  ENTRYPOINT=$(which docker-entrypoint.sh 2>/dev/null || find /usr -name "docker-entrypoint.sh" 2>/dev/null | head -n 1)
  if [ -n "$ENTRYPOINT" ] && [ -f "$ENTRYPOINT" ]; then
    exec "$ENTRYPOINT" "$@"
  else
    echo "Error: Cannot find PostgreSQL entrypoint script" >&2
    echo "Searched in: /usr/local/bin/docker-entrypoint.sh, /docker-entrypoint.sh" >&2
    exit 1
  fi
fi

