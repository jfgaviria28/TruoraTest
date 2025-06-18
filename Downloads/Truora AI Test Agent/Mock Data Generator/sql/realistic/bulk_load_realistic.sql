-- Bulk load REALISTIC CSVs into Supabase PostgreSQL using COPY command
-- Run these commands after connecting via psql to your Supabase instance
-- Make sure you're in the directory containing the 'data' folder
-- 
-- IMPORTANT: Use setup_supabase_realistic.sql first to create tables with correct schemas

-- Load ad platform data (each has different column names and formats)
\copy raw_fb_ads            FROM 'data/raw_fb_ads.csv'            csv header;
\copy raw_google_ads        FROM 'data/raw_google_ads.csv'        csv header;
\copy raw_tiktok_ads        FROM 'data/raw_tiktok_ads.csv'        csv header;
\copy raw_linkedin_ads      FROM 'data/raw_linkedin_ads.csv'      csv header;

-- Load analytics and event data (with renamed columns)
\copy raw_ga4_sessions      FROM 'data/raw_ga4_sessions.csv'      csv header;
\copy raw_mixpanel_events   FROM 'data/raw_mixpanel_events.csv'   csv header;
\copy raw_segment_events    FROM 'data/raw_segment_events.csv'    csv header;

-- Load lead management data (includes duplicates and missing values)
\copy raw_hubspot_leads     FROM 'data/raw_hubspot_leads.csv'     csv header;
\copy raw_intercom_leads    FROM 'data/raw_intercom_leads.csv'    csv header;

-- Load revenue data (NO campaign_id column, Unix timestamps)
\copy raw_stripe_invoices   FROM 'data/raw_stripe_invoices.csv'   csv header;

-- Verify data loaded correctly
SELECT 'fb_ads' as table_name, count(*) as row_count FROM raw_fb_ads
UNION ALL
SELECT 'google_ads', count(*) FROM raw_google_ads  
UNION ALL
SELECT 'tiktok_ads', count(*) FROM raw_tiktok_ads
UNION ALL
SELECT 'linkedin_ads', count(*) FROM raw_linkedin_ads
UNION ALL
SELECT 'ga4_sessions', count(*) FROM raw_ga4_sessions
UNION ALL
SELECT 'mixpanel_events', count(*) FROM raw_mixpanel_events
UNION ALL
SELECT 'segment_events', count(*) FROM raw_segment_events
UNION ALL
SELECT 'hubspot_leads', count(*) FROM raw_hubspot_leads
UNION ALL
SELECT 'intercom_leads', count(*) FROM raw_intercom_leads
UNION ALL
SELECT 'stripe_invoices', count(*) FROM raw_stripe_invoices; 