# Schema Transformation Summary

## 📋 Files Available

| Purpose | Schema File | SQL Setup | SQL Load | SQL Validation |
|---------|-------------|-----------|----------|----------------|
| **Clean Data** | `schema.yaml` | `setup_supabase.sql` | `bulk_load.sql` | `sanity_checks.sql` |
| **Realistic Data** | `schema_realistic.yaml` | `setup_supabase_realistic.sql` | `bulk_load_realistic.sql` | `sanity_checks_realistic.sql` |

## 🧼 CLEAN Schema (Before Entropy)

All files have identical, perfect structure:

```yaml
# Ad platforms: uniform columns
raw_fb_ads:     [date, campaign_id, cost_usd, impressions, clicks]
raw_google_ads: [date, campaign_id, cost_usd, impressions, clicks]
raw_tiktok_ads: [date, campaign_id, cost_usd, impressions, clicks]
raw_linkedin_ads: [date, campaign_id, cost_usd, impressions, clicks]

# Analytics: standard naming
raw_ga4_sessions: [date, session_id, user_uid, campaign_id, conv_flag]
raw_mixpanel_events: [date, user_uid, event_name, campaign_id]
raw_segment_events: [date, session_id, user_uid, campaign_id, event_json]

# Leads: identical structure
raw_hubspot_leads: [lead_id, user_uid, campaign_id, status, deal_amount]
raw_intercom_leads: [lead_id, user_uid, campaign_id, status, deal_amount]

# Revenue: includes campaign_id
raw_stripe_invoices: [invoice_id, user_uid, campaign_id, date, amount_usd]
```

## 🧬 REALISTIC Schema (After Entropy)

Each source has unique quirks:

```yaml
# Ad platforms: all different!
raw_fb_ads:      [date, campaign_id, cost_usd, impressions, clicks, cost_per_click]
raw_google_ads:  [date, campaignId, spend, impressions, clicks]  # MM/DD/YYYY dates
raw_tiktok_ads:  [date, campaign_id, cost_local, currency, impressionsCount, Clicks]
raw_linkedin_ads: [date, campaign_id, cost_usd, impressions, clicks]  # timezone dates

# Analytics: renamed columns
raw_ga4_sessions: [event_date, sessionId, user_uid, campaign_id, conv_flag]
raw_mixpanel_events: [date, user_uid, event_name, campaign_id]  # 5% null user_uid
raw_segment_events: [ts, session_id, uid, campaign_id, properties_json]

# Leads: different structures
raw_hubspot_leads: [lead_id, user_uid, campaign_id, status, deal_amount]  # UNKNOWN/N/A values
raw_intercom_leads: [lead_id, user_uid, campaign_id, status, deal_amount, email]  # with duplicates

# Revenue: missing campaign_id!
raw_stripe_invoices: [invoice_id, user_uid, date, amount_usd]  # Unix timestamps
```

## 🎯 Key Differences Summary

| Source | Clean Format | Realistic Format | Challenge |
|--------|-------------|------------------|-----------|
| **Facebook** | `cost_usd` only | `cost_usd` + `cost_per_click` | Mixed cost models |
| **Google** | ISO dates, `campaign_id` | MM/DD/YYYY, `campaignId`, `spend` | US format + camelCase |
| **TikTok** | USD only | USD/COP/MXN, `cost_local`, `Clicks` | Currency conversion |
| **LinkedIn** | ISO dates | Timezone format | Date parsing |
| **GA4** | `date`, `session_id` | `event_date`, `sessionId` | Column mapping |
| **Segment** | Standard names | `ts`, `uid`, `properties_json` | Alias resolution |
| **HubSpot** | Clean values | "UNKNOWN", "N/A" | Data cleaning |
| **Intercom** | No emails | Email column + duplicates | Deduplication |
| **Stripe** | Has `campaign_id` | **NO** `campaign_id` | Surrogate keys |

## 🚀 Usage

**Generate clean data:**
```bash
cd generator && python make_data.py
# Use: schema.yaml, setup_supabase.sql, bulk_load.sql
```

**Generate realistic data:**
```bash
cd generator && python make_realistic_data.py  
# Use: schema_realistic.yaml, setup_supabase_realistic.sql, bulk_load_realistic.sql
```

The realistic data will challenge your AI agent with **real-world data quality issues**! 🧬 