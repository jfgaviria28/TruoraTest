-- Supabase PostgreSQL table setup for REALISTIC mock marketing data
-- Run this in Supabase SQL Editor before bulk loading CSVs
-- This version handles mixed column names, currencies, date formats, and missing data

-- Facebook Ads (has cost_per_click column for some rows)
create table raw_fb_ads (
  date date, 
  campaign_id text, 
  cost_usd text,  -- TEXT to handle empty values when cost_per_click is used
  impressions int, 
  clicks int,
  cost_per_click numeric  -- Some rows use this instead of cost_usd
);

-- Google Ads (camelCase columns, MM/DD/YYYY dates, some dashed values)
create table raw_google_ads (
  date text,  -- TEXT to handle MM/DD/YYYY format
  campaignId text,  -- camelCase
  spend numeric,  -- renamed from cost_usd
  impressions int, 
  clicks text  -- TEXT to handle "--" values
);

-- TikTok Ads (mixed currencies, European formatting, blank impressions)
create table raw_tiktok_ads (
  date date, 
  campaign_id text, 
  cost_local text,  -- TEXT to handle thousands separators like "1.338.92"
  currency text,    -- USD, COP, MXN
  impressionsCount text,  -- TEXT to handle blank values
  Clicks int  -- Capitalized
);

-- LinkedIn Ads (timezone-aware datetime)
create table raw_linkedin_ads (
  date text,  -- TEXT to handle timezone format "2025-06-15T14:23:15-05:00"
  campaign_id text, 
  cost_usd numeric, 
  impressions int, 
  clicks int
);

-- GA4 Sessions (renamed columns, malformed session IDs)
create table raw_ga4_sessions (
  event_date date,  -- renamed from date
  sessionId text,   -- camelCase, handles malformed IDs
  user_uid text, 
  campaign_id text, 
  conv_flag int
);

-- Mixpanel Events (5% null user_uid)
create table raw_mixpanel_events (
  date date, 
  user_uid text,  -- Can be NULL
  event_name text, 
  campaign_id text
);

-- HubSpot Leads (UNKNOWN statuses, N/A amounts)
create table raw_hubspot_leads (
  lead_id text, 
  user_uid text, 
  campaign_id text,
  status text,  -- Includes "UNKNOWN"
  deal_amount text  -- TEXT to handle "N/A"
);

-- Intercom Leads (includes duplicates with email typos)
create table raw_intercom_leads (
  lead_id text, 
  user_uid text, 
  campaign_id text,
  status text, 
  deal_amount numeric,
  email text  -- Added for duplicate detection
);

-- Stripe Invoices (NO campaign_id, Unix timestamps)
create table raw_stripe_invoices (
  invoice_id text, 
  user_uid text, 
  -- campaign_id removed (realistic!)
  date bigint,  -- Unix timestamp
  amount_usd numeric
);

-- Segment Events (renamed columns)
create table raw_segment_events (
  ts date,  -- renamed from date
  session_id text, 
  uid text,  -- renamed from user_uid
  campaign_id text, 
  properties_json text  -- renamed from event_json
); 