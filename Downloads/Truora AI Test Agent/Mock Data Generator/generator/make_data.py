from faker import Faker
import pandas as pd, numpy as np, uuid, pathlib, yaml, random, datetime as dt

fake = Faker(); Faker.seed(42); random.seed(42); np.random.seed(42)
START, END = dt.date(2025, 5, 17), dt.date(2025, 6, 16)
campaign_ids = [f"CID_{uuid.uuid4().hex[:6]}" for _ in range(20)]

def rand_date():
    delta = END - START
    return START + dt.timedelta(days=random.randint(0, delta.days))

def build_ads(channel):
    rows = []
    for _ in range(90*len(campaign_ids)):
        cid = random.choice(campaign_ids)
        spend = abs(np.random.normal(75, 30))
        rows.append([rand_date(), cid, round(spend,2),
                     int(spend*40+random.randint(50,150)),
                     int(spend*1.2+random.randint(1,10))])
    return pd.DataFrame(rows, columns=yaml.safe_load(open("schema.yaml"))[f"raw_{channel}_ads"]["columns"])

def build_sessions(source):
    rows = []
    for _ in range(24000):
        cid = random.choice(campaign_ids)
        if source == "mixpanel_events":
            # Mixpanel events need event_name instead of conv_flag
            rows.append([rand_date(), uuid.uuid4().hex[:10], 
                        random.choice(["page_view", "click", "signup", "purchase"]), cid])
        elif source == "segment_events":
            # Segment events need event_json instead of conv_flag
            rows.append([rand_date(), uuid.uuid4().hex[:12], uuid.uuid4().hex[:10], cid,
                        '{"event_type": "' + random.choice(["click", "view", "conversion"]) + '"}'])
        else:
            # GA4 sessions with conv_flag
            rows.append([rand_date(), uuid.uuid4().hex[:12], uuid.uuid4().hex[:10], cid,
                         np.random.choice([0,1], p=[0.9,0.1])])
    return pd.DataFrame(rows, columns=yaml.safe_load(open("schema.yaml"))[f"raw_{source}"]["columns"])

# Create all 10 CSVs ----------
out = pathlib.Path("../data"); out.mkdir(exist_ok=True)

for ch in ["fb", "google", "tiktok", "linkedin"]:
    build_ads(ch).to_csv(out/f"raw_{ch}_ads.csv", index=False)

build_sessions("ga4_sessions").to_csv(out/"raw_ga4_sessions.csv", index=False)
build_sessions("mixpanel_events").to_csv(out/"raw_mixpanel_events.csv", index=False)

leads_cols = yaml.safe_load(open("schema.yaml"))["raw_hubspot_leads"]["columns"]
leads = []
for _ in range(3000):
    uid = uuid.uuid4().hex[:10]; cid = random.choice(campaign_ids)
    amt = round(np.random.exponential(500),2)
    leads.append([uuid.uuid4().hex[:8], uid, cid,
                  np.random.choice(["New","Contacted","Qualified"]),
                  amt])
pd.DataFrame(leads, columns=leads_cols).to_csv(out/"raw_hubspot_leads.csv", index=False)
pd.DataFrame(leads, columns=leads_cols).to_csv(out/"raw_intercom_leads.csv", index=False)

inv_cols = yaml.safe_load(open("schema.yaml"))["raw_stripe_invoices"]["columns"]
invoices = []
for l in leads:
    if l[3] == "Qualified":
        invoices.append([uuid.uuid4().hex[:10], l[1], l[2],
                        rand_date(), round(l[4]*1.1,2)])
pd.DataFrame(invoices, columns=inv_cols).to_csv(out/"raw_stripe_invoices.csv", index=False)

build_sessions("segment_events").to_csv(out/"raw_segment_events.csv", index=False)

print("✔ 10 synthetic CSVs in ../data") 