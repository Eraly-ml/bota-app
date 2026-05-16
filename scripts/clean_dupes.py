import urllib.request
import json

SB = "https://nuacawcczjetqwgazemt.supabase.co"
SK = "YOUR_SUPABASE_SERVICE_KEY"

def get(table):
    req = urllib.request.Request(f"{SB}/rest/v1/{table}?select=id&order=id", headers={"apikey":SK,"Authorization":f"Bearer {SK}"})
    return json.loads(urllib.request.urlopen(req).read())

def delete_ids(table, ids):
    for id_val in ids:
        req = urllib.request.Request(
            f"{SB}/rest/v1/{table}?id=eq.{id_val}",
            headers={"apikey":SK,"Authorization":f"Bearer {SK}"},
            method="DELETE"
        )
        urllib.request.urlopen(req)

for table, expected in [("words",12),("quiz_questions",12),("shop_items",6),("candy_images",15),("quest_scenes",4)]:
    rows = get(table)
    if len(rows) > expected:
        extra = [r['id'] for r in rows[expected:]]
        delete_ids(table, extra)
        print(f"{table}: removed {len(extra)} duplicates, kept {expected}")
    else:
        print(f"{table}: OK ({len(rows)} rows)")

print("\nDone!")
