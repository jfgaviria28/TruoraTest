-- Sanity Checks for Clean Mock Data
-- Basic validation queries to ensure data quality

-- Check row counts for all tables
SELECT 'Row Counts Check' as check_name;
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

-- Check for NULL values (should be 0 in clean data)
SELECT 'NULL Values Check' as check_name;
SELECT 'fb_ads' as source, 
       SUM(CASE WHEN campaign_id IS NULL THEN 1 ELSE 0 END) as null_campaign_id,
       SUM(CASE WHEN cost_usd IS NULL THEN 1 ELSE 0 END) as null_cost,
       SUM(CASE WHEN clicks IS NULL THEN 1 ELSE 0 END) as null_clicks,
       SUM(CASE WHEN impressions IS NULL THEN 1 ELSE 0 END) as null_impressions,
       SUM(CASE WHEN event_date IS NULL THEN 1 ELSE 0 END) as null_date
FROM raw_fb_ads
UNION ALL
SELECT 'google_ads', 
       SUM(CASE WHEN campaign_id IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN cost_usd IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN clicks IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN impressions IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN event_date IS NULL THEN 1 ELSE 0 END)
FROM raw_google_ads;

-- Check date ranges
SELECT 'Date Range Check' as check_name;
SELECT 'fb_ads' as source, MIN(event_date) as min_date, MAX(event_date) as max_date, COUNT(DISTINCT event_date) as unique_dates FROM raw_fb_ads
UNION ALL
SELECT 'google_ads', MIN(event_date), MAX(event_date), COUNT(DISTINCT event_date) FROM raw_google_ads
UNION ALL
SELECT 'tiktok_ads', MIN(event_date), MAX(event_date), COUNT(DISTINCT event_date) FROM raw_tiktok_ads
UNION ALL
SELECT 'linkedin_ads', MIN(event_date), MAX(event_date), COUNT(DISTINCT event_date) FROM raw_linkedin_ads
UNION ALL
SELECT 'ga4_sessions', MIN(event_date), MAX(event_date), COUNT(DISTINCT event_date) FROM raw_ga4_sessions
UNION ALL
SELECT 'segment_events', MIN(event_date), MAX(event_date), COUNT(DISTINCT event_date) FROM raw_segment_events
UNION ALL
SELECT 'mixpanel_events', MIN(event_date), MAX(event_date), COUNT(DISTINCT event_date) FROM raw_mixpanel_events
UNION ALL
SELECT 'hubspot_leads', MIN(event_date), MAX(event_date), COUNT(DISTINCT event_date) FROM raw_hubspot_leads
UNION ALL
SELECT 'intercom_leads', MIN(event_date), MAX(event_date), COUNT(DISTINCT event_date) FROM raw_intercom_leads
UNION ALL
SELECT 'stripe_invoices', MIN(event_date), MAX(event_date), COUNT(DISTINCT event_date) FROM raw_stripe_invoices;

-- Check unique campaign_ids across ad platforms
SELECT 'Campaign ID Check' as check_name;
SELECT 'fb_ads' as source, COUNT(DISTINCT campaign_id) as unique_campaigns FROM raw_fb_ads
UNION ALL
SELECT 'google_ads', COUNT(DISTINCT campaign_id) FROM raw_google_ads
UNION ALL
SELECT 'tiktok_ads', COUNT(DISTINCT campaign_id) FROM raw_tiktok_ads
UNION ALL
SELECT 'linkedin_ads', COUNT(DISTINCT campaign_id) FROM raw_linkedin_ads
UNION ALL
SELECT 'hubspot_leads', COUNT(DISTINCT campaign_id) FROM raw_hubspot_leads;

-- Check cost ranges (should be reasonable)
SELECT 'Cost Range Check' as check_name;
SELECT 'fb_ads' as source, MIN(cost_usd) as min_cost, MAX(cost_usd) as max_cost, AVG(cost_usd)::DECIMAL(10,2) as avg_cost FROM raw_fb_ads
UNION ALL
SELECT 'google_ads', MIN(cost_usd), MAX(cost_usd), AVG(cost_usd)::DECIMAL(10,2) FROM raw_google_ads
UNION ALL
SELECT 'tiktok_ads', MIN(cost_usd), MAX(cost_usd), AVG(cost_usd)::DECIMAL(10,2) FROM raw_tiktok_ads
UNION ALL
SELECT 'linkedin_ads', MIN(cost_usd), MAX(cost_usd), AVG(cost_usd)::DECIMAL(10,2) FROM raw_linkedin_ads;

-- Check user_uid consistency
SELECT 'User UID Check' as check_name;
SELECT 'ga4_sessions' as source, COUNT(DISTINCT user_uid) as unique_users FROM raw_ga4_sessions
UNION ALL
SELECT 'segment_events', COUNT(DISTINCT user_uid) FROM raw_segment_events
UNION ALL
SELECT 'mixpanel_events', COUNT(DISTINCT user_uid) FROM raw_mixpanel_events
UNION ALL
SELECT 'hubspot_leads', COUNT(DISTINCT user_uid) FROM raw_hubspot_leads
UNION ALL
SELECT 'intercom_leads', COUNT(DISTINCT user_uid) FROM raw_intercom_leads
UNION ALL
SELECT 'stripe_invoices', COUNT(DISTINCT user_uid) FROM raw_stripe_invoices;

-- Check for duplicate records (should be 0 in clean data)
SELECT 'Duplicate Check' as check_name;
SELECT 'fb_ads duplicates' as check_type, COUNT(*) - COUNT(DISTINCT (campaign_id, event_date, cost_usd, clicks, impressions)) as duplicates FROM raw_fb_ads
UNION ALL
SELECT 'intercom_leads duplicates', COUNT(*) - COUNT(DISTINCT (lead_id, user_uid, email, status, event_date)) FROM raw_intercom_leads;

SELECT 'All sanity checks completed for clean data!' as status; 