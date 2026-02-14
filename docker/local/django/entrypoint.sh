#!/bin/bash

set -o errexit

set -o pipefail

set -o nounset

python << END
import sys
import time
import psycopg2
suggest_unrecoverable_after = 30 
start = time.time()
while True:
    try:
        psycopg2.connect(
        dbname="${POSTGRES_DB}",
        user="${POSTGRES_USER}",
        password="${POSTGRES_PASSWORD}",
        host="${POSTGRES_HOST}",
        port="${POSTGRES_PORT}"
        )
        break
    except psycopg2.OperationalError as e:
        sys.stderr.write(" Wating for Postgres to become available...\n")
        if time.time() - start > suggest_unrecoverable_after:
            sys.stderr.write("This is taking longer than expected. Exiting. The following exception was indicative of a unrecoverable error: '{}'\n".format(e))
            time.sleep(1)

END
echo >&2 "Postgres is available"

exec "$@"