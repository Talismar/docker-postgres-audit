#!/bin/bash
set -e

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  if [ -f "/docker-entrypoint-initdb.d/create_extensions.sql" ]; then
    ORIGINAL_HASH=$(cat /opt/create_extensions.sha256 | awk '{print $1}')
    CURRENT_HASH=$(sha256sum /docker-entrypoint-initdb.d/create_extensions.sql | awk '{print $1}')

    if [ "$ORIGINAL_HASH" != "$CURRENT_HASH" ]; then
      echo "❌ Detected user-modified create_extensions.sql script."
      echo "This file is managed by the system and must not be overridden."
      exit 1
    fi
  fi
fi

echo "✅ Init script validation complete. Starting PostgreSQL..."
exec docker-entrypoint.sh "$@"
