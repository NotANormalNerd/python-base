#!/bin/sh
until pg_isready -h "$POSTGRES_HOST" -U postgres; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - moving to the next step"
exec "$@"