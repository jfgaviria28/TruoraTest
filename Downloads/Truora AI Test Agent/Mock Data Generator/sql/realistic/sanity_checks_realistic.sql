-- Sanity checks for REALISTIC mock marketing data
-- These queries test that entropy features are working correctly

-- 1. Basic row counts (should all be > 0)
SELECT 'Table Counts' as check_type;
SELECT 'fb_ads' as table_name, count(*) as rows FROM raw_fb_ads
UNION ALL SELECT 'google_ads', count(*) FROM raw_google_ads  
UNION ALL SELECT 'tiktok_ads', count(*) FROM raw_tiktok_ads
UNION ALL SELECT 'linkedin_ads', count(*) FROM raw_linkedin_ads
UNION ALL SELECT 'ga4_sessions', count(*) FROM raw_ga4_sessions
UNION ALL SELECT 'mixpanel_events', count(*) FROM raw_mixpanel_events
UNION ALL SELECT 'segment_events', count(*) FROM raw_segment_events
UNION ALL SELECT 'hubspot_leads', count(*) FROM raw_hubspot_leads
UNION ALL SELECT 'intercom_leads', count(*) FROM raw_intercom_leads
UNION ALL SELECT 'stripe_invoices', count(*) FROM raw_stripe_invoices;

-- 2. Test mixed currencies in TikTok
SELECT 'TikTok Currency Mix' as check_type;
SELECT currency, count(*) as count 
FROM raw_tiktok_ads 
GROUP BY currency 
ORDER BY currency;

-- 3. Test missing/null data
SELECT 'Missing Data Check' as check_type;
SELECT 
  'TikTok blank impressions' as field,
  count(*) as blank_count
FROM raw_tiktok_ads 
WHERE impressionsCount = '' OR impressionsCount IS NULL
UNION ALL
SELECT 
  'Mixpanel null user_uid',
  count(*)
FROM raw_mixpanel_events 
WHERE user_uid IS NULL
UNION ALL
SELECT 
  'HubSpot UNKNOWN status',
  count(*)
FROM raw_hubspot_leads 
WHERE status = 'UNKNOWN'
UNION ALL
SELECT 
  'HubSpot N/A amounts',
  count(*)
FROM raw_hubspot_leads 
WHERE deal_amount = 'N/A'
UNION ALL
SELECT 
  'Google dashed clicks',
  count(*)
FROM raw_google_ads 
WHERE clicks = '--';

-- 4. Test date format diversity
SELECT 'Date Format Check' as check_type;
SELECT 
  'Google MM/DD/YYYY' as format,
  date as sample_date
FROM raw_google_ads 
LIMIT 3
UNION ALL
SELECT 
  'Stripe Unix timestamp',
  date::text
FROM raw_stripe_invoices 
LIMIT 3;

-- 5. Test duplicate emails in Intercom
SELECT 'Duplicate Detection' as check_type;
SELECT 
  email,
  count(*) as duplicate_count
FROM raw_intercom_leads 
WHERE email IS NOT NULL
GROUP BY email 
HAVING count(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10;

-- 6. Test Stripe missing campaign_id (should be no campaign_id column)
SELECT 'Stripe Schema Check' as check_type;
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'raw_stripe_invoices' 
AND column_name = 'campaign_id';
-- Should return 0 rows

-- 7. Sample realistic TikTok data with thousands separators
SELECT 'TikTok Sample Data' as check_type;
SELECT 
  date,
  campaign_id,
  cost_local,
  currency,
  impressionsCount as impressions,
  Clicks as clicks
FROM raw_tiktok_ads 
WHERE cost_local LIKE '%.%.%'  -- European thousands separator
LIMIT 5;

-- 8. Test column name variations
SELECT 'Column Name Entropy' as check_type;
SELECT 
  'Google camelCase' as source,
  campaignId as campaign_identifier
FROM raw_google_ads 
LIMIT 1
UNION ALL
SELECT 
  'GA4 renamed columns',
  campaign_id
FROM raw_ga4_sessions 
LIMIT 1
UNION ALL
SELECT 
  'Segment shortened names',
  campaign_id
FROM raw_segment_events 
LIMIT 1;

-- 9. Performance summary despite messy data
SELECT 'Campaign Performance Summary' as check_type;
WITH unified_spend AS (
  -- TikTok: Convert local currency to USD (simplified)
  SELECT 
    campaign_id,
    CASE 
      WHEN currency = 'USD' THEN cost_local::numeric
      WHEN currency = 'MXN' THEN (replace(cost_local, '.', '')::numeric / 17)
      WHEN currency = 'COP' THEN (replace(cost_local, '.', '')::numeric / 4200)
      ELSE 0
    END as spend_usd,
    CASE 
      WHEN impressionsCount = '' THEN 0 
      ELSE impressionsCount::int 
    END as impressions,
    Clicks as clicks
  FROM raw_tiktok_ads
  WHERE cost_local ~ '^[0-9.,]+$'  -- Only numeric-like values
  
  UNION ALL
  
  -- Google: Handle dashed clicks
  SELECT 
    campaignId as campaign_id,
    spend as spend_usd,
    impressions,
    CASE 
      WHEN clicks = '--' THEN 0 
      ELSE clicks::int 
    END as clicks
  FROM raw_google_ads
)
SELECT 
  campaign_id,
  round(sum(spend_usd), 2) as total_spend,
  sum(impressions) as total_impressions,
  sum(clicks) as total_clicks,
  round(sum(clicks)::numeric / nullif(sum(impressions), 0) * 100, 2) as ctr_percent
FROM unified_spend
GROUP BY campaign_id
ORDER BY total_spend DESC
LIMIT 10; 