# Mock Data Generator

A comprehensive tool for generating mock marketing data with two modes: **Clean** (perfect for testing ETL pipelines) and **Realistic** (with real-world data messiness for AI agent training).

## 🎯 Purpose

This tool generates mock data simulating a typical marketing tech stack with data from 10 different sources: Facebook Ads, Google Ads, TikTok Ads, LinkedIn Ads, GA4 Sessions, Segment Events, Mixpanel Events, HubSpot Leads, Intercom Leads, and Stripe Invoices.

**Two Data Modes:**
- **Clean Mode**: Perfect schemas, consistent naming, no missing data - ideal for testing ETL pipelines
- **Realistic Mode**: Real-world messiness with mixed formats, missing data, duplicates - perfect for AI agent training

## 📁 Project Structure

```
Mock Data Generator/
├─ README.md             # This file
├─ requirements.txt      # Python dependencies
├─ data/                 # Generated CSV files (10 sources)
├─ generator/            # Data generation tools
│  ├─ make_data.py       # Clean data generator
│  ├─ schema.yaml        # Clean data schema
│  ├─ add_entropy.py     # Entropy transformation tool
│  ├─ make_realistic_data.py  # Realistic data generator
│  └─ schema_realistic.yaml   # Realistic data schema
├─ sql/                  # Database setup scripts
│  ├─ clean/             # Clean data SQL scripts
│  │  ├─ setup_supabase.sql    # Clean table creation
│  │  ├─ bulk_load.sql         # Clean data loading
│  │  └─ sanity_checks.sql     # Clean data validation
│  └─ realistic/         # Realistic data SQL scripts
│     ├─ setup_supabase_realistic.sql  # Realistic table creation
│     ├─ bulk_load_realistic.sql       # Realistic data loading
│     └─ sanity_checks_realistic.sql   # Realistic data validation
└─ docs/                 # Documentation
   ├─ ENTROPY_SUMMARY.md # Detailed entropy transformations
   └─ SCHEMA_SUMMARY.md  # Schema comparison guide
```

## 🚀 Quick Start

### Prerequisites
```bash
pip install -r requirements.txt
```

### Option 1: Clean Data (Perfect for ETL Testing)

1. **Generate clean data:**
   ```bash
   cd generator
   python make_data.py
   ```

2. **Setup database:**
   Copy and run `sql/clean/setup_supabase.sql` in your database

3. **Load data:**
   Copy and paste the contents of `sql/clean/bulk_load.sql`

4. **Validate:**
   Run queries in `sql/clean/sanity_checks.sql` for basic validation

### Option 2: Realistic Data (Perfect for AI Agent Training)

1. **Generate realistic data:**
   ```bash
   cd generator
   python make_realistic_data.py
   ```

2. **Setup database:**
   Copy and run `sql/realistic/setup_supabase_realistic.sql` in your database

3. **Load data:**
   Copy and paste the contents of `sql/realistic/bulk_load_realistic.sql`

4. **Validate:**
   Run queries in `sql/realistic/sanity_checks_realistic.sql` for entropy validation

## 📊 Data Sources

| Source | Records | Key Fields | Notes |
|--------|---------|------------|-------|
| Facebook Ads | 60 | campaign_id, cost, clicks, impressions | Ad performance data |
| Google Ads | 60 | campaign_id, cost, clicks, impressions | Search ad metrics |
| TikTok Ads | 60 | campaign_id, cost, clicks, impressions | Social ad data |
| LinkedIn Ads | 60 | campaign_id, cost, clicks, impressions | B2B ad metrics |
| GA4 Sessions | 60 | session_id, user_uid, page_views | Web analytics |
| Segment Events | 60 | event_id, user_uid, event_type | Event tracking |
| Mixpanel Events | 60 | event_id, user_uid, event_type | Product analytics |
| HubSpot Leads | 60 | lead_id, user_uid, campaign_id | CRM leads |
| Intercom Leads | 60 | lead_id, user_uid, email | Chat leads |
| Stripe Invoices | 60 | invoice_id, user_uid, amount | Payment data |

## 🎭 Clean vs Realistic Data

### Clean Data Features:
- ✅ Consistent column names (`campaign_id`, `cost_usd`, `user_uid`)
- ✅ Standard date format (ISO-8601: `2024-01-15`)
- ✅ All USD currency, decimal format
- ✅ No missing data, no duplicates
- ✅ Perfect key relationships

### Realistic Data Features:
- 🌪️ **Mixed column names**: `campaignId`, `Spend`, `cost_local`, `Clicks`
- 🌪️ **Mixed currencies**: USD, COP, MXN with European formatting (`1.338.92`)
- 🌪️ **Mixed date formats**: MM/DD/YYYY, timezone-aware, Unix timestamps
- 🌪️ **Missing data**: 10% blank impressions, 5% null user_uid, `UNKNOWN` statuses
- 🌪️ **Key mismatches**: Stripe missing `campaign_id`, forces surrogate keys
- 🌪️ **Duplicates**: 2% Intercom leads with email typos

## 🔍 Use Cases

### Clean Data Perfect For:
- ETL pipeline development and testing
- Data warehouse schema design
- Performance benchmarking
- Educational purposes

### Realistic Data Perfect For:
- AI agent training and testing
- Data quality assessment tools
- Real-world data integration challenges
- Column mapping and transformation logic

## 🛠️ Troubleshooting

### Common Issues:

1. **Import errors**: Check you're in the `generator/` directory
2. **File not found**: Ensure CSV files are generated before SQL import
3. **Date parsing errors**: Use realistic SQL schema for mixed date formats
4. **Currency conversion**: Check FX rates in entropy transformations
5. **Missing campaign_id**: Stripe realistic data intentionally excludes this field

### Files to Check:
- Check file paths in `sql/*/bulk_load*.sql`
- Verify column mappings in realistic schema
- Review entropy transformations in `docs/ENTROPY_SUMMARY.md`

## 📈 Advanced Usage

For detailed information about the entropy transformations and schema differences, see:
- `docs/ENTROPY_SUMMARY.md` - Complete entropy transformation details
- `docs/SCHEMA_SUMMARY.md` - Clean vs realistic schema comparison

The realistic data includes sophisticated transformations including:
- Multi-currency data with accurate exchange rates
- Realistic null/missing data patterns
- Email typos and duplicate generation
- Mixed timestamp formats matching real platform behaviors

---

**Need help?** Check the troubleshooting section or review the documentation in the `docs/` folder. 