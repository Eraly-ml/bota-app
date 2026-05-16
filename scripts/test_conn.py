import pg8000
import json
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

print("Trying pooler connection...")
try:
    conn = pg8000.connect(
        host="aws-0-eu-central-1.pooler.supabase.com",
        port=6543,
        user="postgres.nuacawcczjetqwgazemt",
        password="Alikhan303-",
        database="postgres",
        ssl_context=ctx,
    )
    conn.autocommit = True
    cur = conn.cursor()
    cur.execute("SELECT 1")
    print(f"Connected via pooler! Test: {cur.fetchone()}")
    conn.close()
except Exception as e:
    print(f"Pooler failed: {e}")

print("\nTrying transaction pooler (port 5432)...")
try:
    conn = pg8000.connect(
        host="aws-0-eu-central-1.pooler.supabase.com",
        port=5432,
        user="postgres.nuacawcczjetqwgazemt",
        password="Alikhan303-",
        database="postgres",
        ssl_context=ctx,
    )
    conn.autocommit = True
    cur = conn.cursor()
    cur.execute("SELECT 1")
    print(f"Connected via transaction pooler! Test: {cur.fetchone()}")
    conn.close()
except Exception as e:
    print(f"Transaction pooler failed: {e}")
