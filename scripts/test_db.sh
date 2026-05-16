#!/bin/bash
SB_URL="https://nuacawcczjetqwgazemt.supabase.co"
SK="YOUR_SUPABASE_SERVICE_KEY"

run_sql() {
  local sql="$1"
  local desc="$2"
  echo -n "$desc... "
  local resp=$(curl -s -X POST "$SB_URL/rest/v1/rpc/exec_sql" \
    -H "apikey: $SK" \
    -H "Authorization: Bearer $SK" \
    -H "Content-Type: application/json" \
    -d "{\"sql\": $(echo "$sql" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')}")
  echo "$resp" | head -c 120
  echo ""
}

echo "=== Creating tables via pg connection ==="

PGPASSWORD="Alikhan303-" psql "postgresql://postgres.nuacawcczjetqwgazemt:Alikhan303-@aws-0-eu-central-1.pooler.supabase.com:6543/postgres" -c "SELECT 1 as test;" 2>&1 | head -5

echo "Trying direct connection..."
PGPASSWORD="Alikhan303-" psql "postgresql://postgres:Alikhan303-@db.nuacawcczjetqwgazemt.supabase.co:5432/postgres" -c "SELECT 1;" 2>&1 | head -5
