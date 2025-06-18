# Clean Project Structure

## 📁 Organization Overview

The project has been reorganized for clarity with these key improvements:

### ✅ What's New:
- **Separated SQL scripts** by type (clean vs realistic)
- **Organized documentation** in dedicated `docs/` folder  
- **Centralized generator tools** in `generator/` directory
- **Updated README** with clear instructions for both modes
- **Removed duplicates** and system files

### 📂 Final Directory Structure:

```
Mock Data Generator/
├─ README.md             # Main documentation (updated)
├─ requirements.txt      # Python dependencies
├─ PROJECT_STRUCTURE.md  # This file (for reference)
│
├─ data/                 # Generated CSV files (10 sources)
│  ├─ raw_fb_ads.csv
│  ├─ raw_google_ads.csv
│  ├─ raw_tiktok_ads.csv
│  ├─ raw_linkedin_ads.csv
│  ├─ raw_ga4_sessions.csv
│  ├─ raw_segment_events.csv
│  ├─ raw_mixpanel_events.csv
│  ├─ raw_hubspot_leads.csv
│  ├─ raw_intercom_leads.csv
│  └─ raw_stripe_invoices.csv
│
├─ generator/            # Data generation tools
│  ├─ make_data.py       # Generate clean data
│  ├─ schema.yaml        # Clean data schema
│  ├─ make_realistic_data.py  # Generate realistic data
│  ├─ schema_realistic.yaml   # Realistic data schema
│  └─ add_entropy.py     # Entropy transformation engine
│
├─ sql/                  # Database setup scripts
│  ├─ clean/             # Clean data SQL scripts
│  │  ├─ setup_supabase.sql   # Create clean tables
│  │  ├─ bulk_load.sql        # Load clean data
│  │  └─ sanity_checks.sql    # Validate clean data
│  └─ realistic/         # Realistic data SQL scripts
│     ├─ setup_supabase_realistic.sql  # Create realistic tables
│     ├─ bulk_load_realistic.sql       # Load realistic data
│     └─ sanity_checks_realistic.sql   # Validate realistic data
│
└─ docs/                 # Documentation
   ├─ ENTROPY_SUMMARY.md # Detailed entropy transformations
   └─ SCHEMA_SUMMARY.md  # Schema comparison guide
```

## 🎯 Quick Usage Paths:

### Clean Data:
```bash
cd generator && python make_data.py
# Then use sql/clean/* files
```

### Realistic Data:
```bash
cd generator && python make_realistic_data.py  
# Then use sql/realistic/* files
```

## 🧹 Cleanup Summary:

**Removed:**
- Duplicate `add_entropy.py` from root
- System files (`.DS_Store`)
- Scattered SQL files in root

**Organized:**
- SQL scripts into `sql/clean/` and `sql/realistic/`
- Documentation into `docs/`
- All generator tools in `generator/`

**Updated:**
- Main README with clear structure
- File paths in documentation
- References to new organization

The project is now much cleaner and easier to navigate! 