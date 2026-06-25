#!/bin/sh

set -e

# -------------------------------------------------
# n8n Heroku entrypoint
# -------------------------------------------------

# If PORT variable is set by Heroku, map it to n8n's port
if [ -z "${PORT+x}" ]; then
  echo "PORT variable not defined, leaving n8n to default port."
else
  export N8N_PORT="$PORT"
  echo "N8N will start on port '$PORT'"
fi

# Parse DATABASE_URL provided by Heroku Postgres addon
parse_url() {
  eval $(echo "$1" | sed -e "s#^\(\(.*\)://\)\?\(\([^:@]*\)\(:\(.*\)\)\?@\)\?\([^/?]*\)\(/\(.*\)\)\?#${PREFIX:-URL_}SCHEME='\2' ${PREFIX:-URL_}USER='\4' ${PREFIX:-URL_}PASSWORD='\6' ${PREFIX:-URL_}HOSTPORT='\7' ${PREFIX:-URL_}DATABASE='\9'#")
}

PREFIX="N8N_DB_" parse_url "$DATABASE_URL"
echo "Using database: $N8N_DB_SCHEME://$N8N_DB_USER:***@$N8N_DB_HOSTPORT/$N8N_DB_DATABASE"

N8N_DB_HOST="$(echo $N8N_DB_HOSTPORT | sed -e 's,:.*,,g')"
N8N_DB_PORT="$(echo $N8N_DB_HOSTPORT | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"

export DB_TYPE=postgresdb
export DB_POSTGRESDB_HOST=$N8N_DB_HOST
export DB_POSTGRESDB_PORT=$N8N_DB_PORT
export DB_POSTGRESDB_DATABASE=$N8N_DB_DATABASE
export DB_POSTGRESDB_USER=$N8N_DB_USER
export DB_POSTGRESDB_PASSWORD=$N8N_DB_PASSWORD

# Ensure N8N_PROTOCOL is set
if [ -z "$N8N_PROTOCOL" ]; then
  export N8N_PROTOCOL=https
fi

# Ensure NODE_ENV is production
if [ -z "$NODE_ENV" ]; then
  export NODE_ENV=production
fi

# Warn if N8N_ENCRYPTION_KEY is not set or is default
if [ -z "$N8N_ENCRYPTION_KEY" ] || [ "$N8N_ENCRYPTION_KEY" = "change-me-to-a-random-32-char-string" ]; then
  echo "WARNING: N8N_ENCRYPTION_KEY is not set to a secure random value!"
fi

# Warn if WEBHOOK_URL still has placeholder
if echo "${WEBHOOK_URL:-}" | grep -qi "<app-name>"; then
  echo "WARNING: WEBHOOK_URL still contains '<app-name>' placeholder! Update it to your actual Heroku app URL."
fi

# Start n8n
exec n8n
