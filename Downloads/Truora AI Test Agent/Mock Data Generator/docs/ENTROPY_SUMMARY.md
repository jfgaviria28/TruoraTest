# Data Entropy Transformation Summary

## ✅ Successfully Applied Transformations

### A. Column Name & Case Scrambling
- **TikTok Ads**: 
  - `cost_usd` → `cost_local` with mixed currencies (USD/COP/MXN)
  - `clicks` → `Clicks` (capitalized)
  - `impressions` → `impressionsCount` (camelCase)
  - Added thousands separators with European formatting (1.234.56)

- **Google Ads**: 
  - Date format: `2025-06-09` → `06/09/2025` (MM/DD/YYYY)
  - `campaign_id` → `campaignId` (camelCase)
  - `cost_usd` → `spend` (different terminology)

- **Segment Events**: 
  - `date` → `ts` (timestamp abbreviation)
  - `user_uid` → `uid` (shorter)
  - `event_json` → `properties_json` (different naming)

### B. Mixed Currencies & Numeric Formats
- **TikTok**: Now has mixed COP (Colombian Peso), MXN (Mexican Peso), USD
- Approximate FX rates applied: USD=1, COP=4200, MXN=17
- European-style thousands separators for Latin American currencies
- Examples: `231.462.00 COP`, `1.337.39 MXN`, `62.12 USD`

### C. Divergent Date Formats
- **Google Ads**: MM/DD/YYYY format (`06/09/2025`)
- **LinkedIn**: ISO-8601 with timezone (planned: `2025-06-15T14:23:15-05:00`)
- **Stripe**: Unix timestamps (`1747958400`)
- **Others**: Standard ISO dates (`2025-06-09`)

### D. Realistic Nulls & Missing Data
- **TikTok**: 10% blank `impressionsCount` values
- **Mixpanel**: 5% null `user_uid` values
- **HubSpot**: 8% "UNKNOWN" status values + 3% "N/A" deal amounts
- **Google Ads**: 4% "--" values for clicks (low-performing campaigns)

### E. Key Mismatches & Duplicates
- **Stripe**: Removed `campaign_id` entirely (now only joins via `user_uid`)
- **Intercom**: Added 20 duplicate leads with email typos:
  - `user_abc@company.com` → `user_abc@gcompany.com`
  - `user_def@company.com` → `user.def@company.co`
  - Minor deal amount variations in duplicates

### F. Additional Messiness
- **Facebook**: 15% of rows use `cost_per_click` instead of `cost_usd`
- **GA4**: 3% malformed session IDs (uppercase, different format)

## 🎯 Testing Challenges Now Present

Your AI agent pipeline must now handle:

1. **Column Mapping**: Map `spend` ↔ `cost_usd` ↔ `cost_local`, `Clicks` ↔ `clicks`, etc.
2. **Currency Conversion**: Convert COP/MXN amounts to USD using exchange rates
3. **Date Parsing**: Handle MM/DD/YYYY, Unix timestamps, ISO-8601 with timezones
4. **Data Cleaning**: Handle nulls, blanks, "N/A", "--", "UNKNOWN" values
5. **Deduplication**: Fuzzy match emails with typos (`@company.com` vs `@compamy.co`)
6. **Surrogate Keys**: Join Stripe data without campaign_id (user_uid only)
7. **Format Normalization**: Parse European-style thousands separators

## 📊 Example Data Samples

### TikTok (Mixed Everything)
```csv
date,campaign_id,cost_local,currency,impressionsCount,Clicks
2025-06-14,CID_5b90c9,231.462.00,COP,2341,69
2025-06-07,CID_5e26dc,62.12,USD,2534,78
2025-06-08,CID_4bd7a0,1.337.39,MXN,,99  # blank impressions
```

### Google Ads (US Format)
```csv
date,campaignId,spend,impressions,clicks
06/09/2025,CID_ea850a,97.71,3998,121
06/01/2025,CID_d4961d,47.34,2008,--  # dashed clicks
```

### Stripe (No Campaign ID)
```csv
invoice_id,user_uid,date,amount_usd
02d8c80c78,86c8a43c47,1716854400,503.11  # unix timestamp
```

This is **much more realistic** than the original "too clean" data! 🧬 