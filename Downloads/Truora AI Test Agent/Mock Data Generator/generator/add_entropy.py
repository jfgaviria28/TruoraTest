#!/usr/bin/env python3
"""
Add realistic entropy to the "too clean" mock data.
Implements the 5 high-leverage tweaks for data realism.
"""

import pandas as pd
import numpy as np
import random
import os
from pathlib import Path

# Seed for reproducible chaos
random.seed(42)
np.random.seed(42)

# Change to parent directory to access data folder
os.chdir('..')

def add_column_name_entropy():
    """A. Scramble column names & cases across different sources"""
    
    print("🔧 Adding column name entropy...")
    
    # TikTok: Mixed currencies + renamed columns + thousands separators
    df = pd.read_csv('data/raw_tiktok_ads.csv')
    
    # Skip if already transformed
    if 'cost_local' in df.columns:
        print("✓ TikTok: Already transformed, skipping")
    else:
        # Add currency column and convert some costs
        currencies = ['USD', 'COP', 'MXN']
        df['currency'] = np.random.choice(currencies, len(df))
        
        # Convert costs based on currency (rough FX rates)
        fx_rates = {'USD': 1, 'COP': 4200, 'MXN': 17}
        df['cost_local'] = df.apply(lambda row: round(row['cost_usd'] * fx_rates[row['currency']], 2), axis=1)
        
        # Add thousands separators for some values
        def format_with_separators(value, currency):
            if currency in ['COP', 'MXN'] and random.random() < 0.7:
                return f"{value:,.2f}".replace(',', '.')  # European style
            elif currency == 'USD' and random.random() < 0.5:
                return f"{value:,.2f}"
            return str(value)
        
        df['cost_local'] = df.apply(lambda row: format_with_separators(row['cost_local'], row['currency']), axis=1)
        
        # Rename columns to create entropy
        df = df.rename(columns={
            'cost_usd': 'Spend',  # Different case
            'clicks': 'Clicks',   # Different case
            'impressions': 'impressionsCount'  # camelCase
        })
        
        # Drop original cost column, keep local
        df = df.drop('Spend', axis=1)
        df = df[['date', 'campaign_id', 'cost_local', 'currency', 'impressionsCount', 'Clicks']]
        
        df.to_csv('data/raw_tiktok_ads.csv', index=False)
        print("✓ TikTok: Added mixed currencies, renamed columns, thousands separators")
    
    # Google Ads: Different date format + camelCase
    df = pd.read_csv('data/raw_google_ads.csv')
    
    if 'campaignId' in df.columns:
        print("✓ Google Ads: Already transformed, skipping")
    else:
        # Convert dates to MM/DD/YYYY format
        df['date'] = pd.to_datetime(df['date']).dt.strftime('%m/%d/%Y')
        
        # Rename to camelCase
        df = df.rename(columns={
            'campaign_id': 'campaignId',
            'cost_usd': 'spend',
            'impressions': 'impressions'  # keep same
        })
        
        df.to_csv('data/raw_google_ads.csv', index=False)
        print("✓ Google Ads: MM/DD/YYYY dates, camelCase columns")
    
    # LinkedIn: Different datetime format
    df = pd.read_csv('data/raw_linkedin_ads.csv')
    
    # Check if already transformed by looking for timezone format
    sample_date = str(df['date'].iloc[0])
    if 'T' in sample_date and '-05:00' in sample_date:
        print("✓ LinkedIn: Already transformed, skipping")
    else:
        # Convert to timezone-aware datetime with random times
        def add_random_time(date_str):
            base_date = pd.to_datetime(date_str)
            random_time = f"{random.randint(0,23):02d}:{random.randint(0,59):02d}:{random.randint(0,59):02d}"
            return f"{base_date.strftime('%Y-%m-%d')}T{random_time}-05:00"
        
        df['date'] = df['date'].apply(add_random_time)
        
        df.to_csv('data/raw_linkedin_ads.csv', index=False)
        print("✓ LinkedIn: Timezone-aware datetime format")
    
    # GA4: Different column names
    df = pd.read_csv('data/raw_ga4_sessions.csv')
    if 'event_date' in df.columns:
        print("✓ GA4: Already transformed, skipping")
    else:
        df = df.rename(columns={
            'date': 'event_date',
            'session_id': 'sessionId'
        })
        df.to_csv('data/raw_ga4_sessions.csv', index=False)
        print("✓ GA4: Renamed to event_date, sessionId")
    
    # Segment: Completely different naming
    df = pd.read_csv('data/raw_segment_events.csv')
    if 'ts' in df.columns:
        print("✓ Segment: Already transformed, skipping")
    else:
        df = df.rename(columns={
            'date': 'ts',
            'user_uid': 'uid',
            'event_json': 'properties_json'
        })
        df.to_csv('data/raw_segment_events.csv', index=False)
        print("✓ Segment: Renamed to ts, uid, properties_json")

def add_realistic_nulls():
    """D. Add realistic nulls, blanks, and 'UNKNOWN' values"""
    
    print("\n🕳️  Adding realistic nulls and missing data...")
    
    # TikTok: 10% of impressions blank (using updated column name)
    df = pd.read_csv('data/raw_tiktok_ads.csv')
    if 'impressionsCount' in df.columns:
        null_mask = np.random.random(len(df)) < 0.10
        df.loc[null_mask, 'impressionsCount'] = ''
        df.to_csv('data/raw_tiktok_ads.csv', index=False)
        print("✓ TikTok: 10% blank impressions")
    
    # Mixpanel: 5% user_uid null
    df = pd.read_csv('data/raw_mixpanel_events.csv')
    null_mask = np.random.random(len(df)) < 0.05
    df.loc[null_mask, 'user_uid'] = np.nan
    df.to_csv('data/raw_mixpanel_events.csv', index=False)
    print("✓ Mixpanel: 5% null user_uid")
    
    # HubSpot: Some 'UNKNOWN' statuses
    df = pd.read_csv('data/raw_hubspot_leads.csv')
    unknown_mask = np.random.random(len(df)) < 0.08
    df.loc[unknown_mask, 'status'] = 'UNKNOWN'
    
    # Also add some "N/A" deal amounts
    na_mask = np.random.random(len(df)) < 0.03
    df.loc[na_mask, 'deal_amount'] = 'N/A'
    
    df.to_csv('data/raw_hubspot_leads.csv', index=False)
    print("✓ HubSpot: Added UNKNOWN statuses, N/A deal amounts")
    
    # Google Ads: Some "--" values for low-performing campaigns
    df = pd.read_csv('data/raw_google_ads.csv')
    dash_mask = np.random.random(len(df)) < 0.04
    df.loc[dash_mask, 'clicks'] = '--'
    df.to_csv('data/raw_google_ads.csv', index=False)
    print("✓ Google Ads: Added '--' for some clicks")

def add_key_mismatches():
    """E. Remove campaign_id from Stripe, add duplicates to Intercom"""
    
    print("\n🔑 Adding key mismatches and duplicates...")
    
    # Remove campaign_id from Stripe invoices (shouldn't naturally have it)
    df = pd.read_csv('data/raw_stripe_invoices.csv')
    if 'campaign_id' in df.columns:
        df = df.drop('campaign_id', axis=1)
        df.to_csv('data/raw_stripe_invoices.csv', index=False)
        print("✓ Stripe: Removed campaign_id (now only joins via user_uid)")
    else:
        print("✓ Stripe: campaign_id already removed")
    
    # Add duplicates to Intercom with email typos
    df = pd.read_csv('data/raw_intercom_leads.csv')
    
    if 'email' not in df.columns:
        # Create email column based on user_uid
        df['email'] = df['user_uid'].apply(lambda x: f"user_{x}@company.com")
        
        # Duplicate 2% of rows with typos
        duplicate_indices = np.random.choice(df.index, size=int(len(df) * 0.02), replace=False)
        duplicates = df.loc[duplicate_indices].copy()
        
        # Add typos to emails in duplicates
        def add_email_typo(email):
            typos = [
                lambda e: e.replace('@', '@g'),  # Extra character
                lambda e: e.replace('.com', '.co'),  # Missing character
                lambda e: e.replace('_', '.'),  # Character substitution
                lambda e: e.replace('company', 'compamy'),  # Transposition
            ]
            return random.choice(typos)(email)
        
        duplicates['email'] = duplicates['email'].apply(add_email_typo)
        
        # Slightly modify other fields in duplicates
        duplicates['lead_id'] = duplicates['lead_id'].apply(lambda x: x[:-1] + random.choice('abcdef'))
        duplicates['deal_amount'] = duplicates['deal_amount'] * (1 + np.random.normal(0, 0.05))
        
        # Concatenate original + duplicates
        df_with_dupes = pd.concat([df, duplicates], ignore_index=True)
        df_with_dupes.to_csv('data/raw_intercom_leads.csv', index=False)
        print(f"✓ Intercom: Added {len(duplicates)} duplicates with email typos")
    else:
        print("✓ Intercom: Email duplicates already added")

def add_date_format_entropy():
    """C. Add divergent date formats across sources"""
    
    print("\n📅 Adding divergent date formats...")
    
    # Stripe: Unix timestamps
    df = pd.read_csv('data/raw_stripe_invoices.csv')
    # Check if already converted (unix timestamps are large numbers)
    sample_date = df['date'].iloc[0]
    if isinstance(sample_date, (int, float)) or (isinstance(sample_date, str) and sample_date.isdigit()):
        print("✓ Stripe: Already converted to Unix timestamps")
    else:
        df['date'] = pd.to_datetime(df['date']).astype(int) // 10**9  # Unix timestamp
        df.to_csv('data/raw_stripe_invoices.csv', index=False)
        print("✓ Stripe: Converted to Unix timestamps")

def add_more_entropy():
    """Additional realistic messiness"""
    
    print("\n🎯 Adding additional entropy...")
    
    # Facebook: Add some rows with cost_per_click instead of total cost
    df = pd.read_csv('data/raw_fb_ads.csv')
    
    if 'cost_per_click' not in df.columns:
        # Add cost_per_click column
        df['cost_per_click'] = np.nan
        
        # For 15% of rows, convert to CPC format
        cpc_mask = np.random.random(len(df)) < 0.15
        df.loc[cpc_mask, 'cost_per_click'] = (df.loc[cpc_mask, 'cost_usd'] / df.loc[cpc_mask, 'clicks']).round(2)
        df.loc[cpc_mask, 'cost_usd'] = ''  # Empty out total cost
        
        df.to_csv('data/raw_fb_ads.csv', index=False)
        print("✓ Facebook: 15% rows now use cost_per_click instead of cost_usd")
    else:
        print("✓ Facebook: cost_per_click already added")
    
    # GA4: Add some malformed session IDs
    df = pd.read_csv('data/raw_ga4_sessions.csv')
    session_col = 'sessionId' if 'sessionId' in df.columns else 'session_id'
    
    malformed_mask = np.random.random(len(df)) < 0.03
    df.loc[malformed_mask, session_col] = df.loc[malformed_mask, session_col].apply(
        lambda x: x.upper() if random.random() < 0.5 else f"sess_{x[:6]}"
    )
    df.to_csv('data/raw_ga4_sessions.csv', index=False)
    print("✓ GA4: Added malformed session IDs")

if __name__ == "__main__":
    print("🧬 Adding realistic entropy to mock data...")
    print("=" * 50)
    
    try:
        add_column_name_entropy()
        add_realistic_nulls()
        add_key_mismatches()
        add_date_format_entropy()
        add_more_entropy()
        
        print("\n" + "=" * 50)
        print("✅ Data entropy added! Now your pipeline will face:")
        print("  • Column name/case mismatches requiring alias mapping")
        print("  • Mixed currencies needing FX conversion") 
        print("  • Multiple date formats requiring normalization")
        print("  • Missing/null data requiring imputation")
        print("  • Duplicates needing fuzzy matching")
        print("  • Key mismatches forcing surrogate key generation")
        print("\n🎯 Much more realistic data for testing!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print("Make sure you're running this from the generator directory.") 