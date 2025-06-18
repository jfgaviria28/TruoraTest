-- Bulk Load Script for Clean Mock Data
-- Run this after creating the database schema with setup_supabase.sql

-- Load Facebook Ads data
\copy raw_fb_ads FROM './data/raw_fb_ads.csv' WITH (FORMAT csv, HEADER true);

-- Load Google Ads data  
\copy raw_google_ads FROM './data/raw_google_ads.csv' WITH (FORMAT csv, HEADER true);

-- Load TikTok Ads data
\copy raw_tiktok_ads FROM './data/raw_tiktok_ads.csv' WITH (FORMAT csv, HEADER true);

-- Load LinkedIn Ads data
\copy raw_linkedin_ads FROM './data/raw_linkedin_ads.csv' WITH (FORMAT csv, HEADER true);

-- Load GA4 Sessions data
\copy raw_ga4_sessions FROM './data/raw_ga4_sessions.csv' WITH (FORMAT csv, HEADER true);

-- Load Segment Events data
\copy raw_segment_events FROM './data/raw_segment_events.csv' WITH (FORMAT csv, HEADER true);

-- Load Mixpanel Events data
\copy raw_mixpanel_events FROM './data/raw_mixpanel_events.csv' WITH (FORMAT csv, HEADER true);

-- Load HubSpot Leads data
\copy raw_hubspot_leads FROM './data/raw_hubspot_leads.csv' WITH (FORMAT csv, HEADER true);

-- Load Intercom Leads data
\copy raw_intercom_leads FROM './data/raw_intercom_leads.csv' WITH (FORMAT csv, HEADER true);

-- Load Stripe Invoices data
\copy raw_stripe_invoices FROM './data/raw_stripe_invoices.csv' WITH (FORMAT csv, HEADER true);

-- Verify the data load
SELECT 'raw_fb_ads' as table_name, count(*) as row_count FROM raw_fb_ads
UNION ALL
SELECT 'raw_google_ads', count(*) FROM raw_google_ads
UNION ALL  
SELECT 'raw_tiktok_ads', count(*) FROM raw_tiktok_ads
UNION ALL
SELECT 'raw_linkedin_ads', count(*) FROM raw_linkedin_ads
UNION ALL
SELECT 'raw_ga4_sessions', count(*) FROM raw_ga4_sessions
UNION ALL
SELECT 'raw_segment_events', count(*) FROM raw_segment_events
UNION ALL
SELECT 'raw_mixpanel_events', count(*) FROM raw_mixpanel_events
UNION ALL
SELECT 'raw_hubspot_leads', count(*) FROM raw_hubspot_leads
UNION ALL
SELECT 'raw_intercom_leads', count(*) FROM raw_intercom_leads
UNION ALL
SELECT 'raw_stripe_invoices', count(*) FROM raw_stripe_invoices
ORDER BY table_name; 