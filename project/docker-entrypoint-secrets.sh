#!/bin/sh
set -e

# Lire les secrets depuis les fichiers _FILE si disponibles
if [ -n "$POSTGRES_USER_FILE" ] && [ -f "$POSTGRES_USER_FILE" ]; then
  export POSTGRES_USER=$(cat "$POSTGRES_USER_FILE" | tr -d '\n\r ')
fi

if [ -n "$POSTGRES_DB_FILE" ] && [ -f "$POSTGRES_DB_FILE" ]; then
  export POSTGRES_DB=$(cat "$POSTGRES_DB_FILE" | tr -d '\n\r ')
fi

exec /usr/local/bin/docker-entrypoint.sh "$@"

