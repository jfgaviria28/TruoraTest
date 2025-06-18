-- Supabase Database Setup for Clean Mock Data
-- This script creates tables with consistent column names and standard data types

-- Facebook Ads data
CREATE TABLE IF NOT EXISTS raw_fb_ads (
    campaign_id TEXT NOT NULL,
    cost_usd DECIMAL(10,2) NOT NULL,
    clicks INTEGER NOT NULL,
    impressions INTEGER NOT NULL,
    event_date DATE NOT NULL
);

-- Google Ads data  
CREATE TABLE IF NOT EXISTS raw_google_ads (
    campaign_id TEXT NOT NULL,
    cost_usd DECIMAL(10,2) NOT NULL,
    clicks INTEGER NOT NULL,
    impressions INTEGER NOT NULL,
    event_date DATE NOT NULL
);

-- TikTok Ads data
CREATE TABLE IF NOT EXISTS raw_tiktok_ads (
    campaign_id TEXT NOT NULL,
    cost_usd DECIMAL(10,2) NOT NULL,
    clicks INTEGER NOT NULL,
    impressions INTEGER NOT NULL,
    event_date DATE NOT NULL
);

-- LinkedIn Ads data
CREATE TABLE IF NOT EXISTS raw_linkedin_ads (
    campaign_id TEXT NOT NULL,
    cost_usd DECIMAL(10,2) NOT NULL,
    clicks INTEGER NOT NULL,
    impressions INTEGER NOT NULL,
    event_date DATE NOT NULL
);

-- GA4 Sessions data
CREATE TABLE IF NOT EXISTS raw_ga4_sessions (
    session_id TEXT NOT NULL,
    user_uid TEXT NOT NULL,
    event_date DATE NOT NULL,
    page_views INTEGER NOT NULL,
    session_duration INTEGER NOT NULL
);

-- Segment Events data
CREATE TABLE IF NOT EXISTS raw_segment_events (
    event_id TEXT NOT NULL,
    user_uid TEXT NOT NULL,
    event_date DATE NOT NULL,
    event_type TEXT NOT NULL,
    properties_json JSONB
);

-- Mixpanel Events data
CREATE TABLE IF NOT EXISTS raw_mixpanel_events (
    event_id TEXT NOT NULL,
    user_uid TEXT NOT NULL,
    event_date DATE NOT NULL,
    event_type TEXT NOT NULL,
    properties_json JSONB
);

-- HubSpot Leads data
CREATE TABLE IF NOT EXISTS raw_hubspot_leads (
    lead_id TEXT NOT NULL,
    user_uid TEXT NOT NULL,
    campaign_id TEXT NOT NULL,
    status TEXT NOT NULL,
    event_date DATE NOT NULL
);

-- Intercom Leads data
CREATE TABLE IF NOT EXISTS raw_intercom_leads (
    lead_id TEXT NOT NULL,
    user_uid TEXT NOT NULL,
    email TEXT NOT NULL,
    status TEXT NOT NULL,
    event_date DATE NOT NULL
);

-- Stripe Invoices data
CREATE TABLE IF NOT EXISTS raw_stripe_invoices (
    invoice_id TEXT NOT NULL,
    user_uid TEXT NOT NULL,
    amount_usd DECIMAL(10,2) NOT NULL,
    status TEXT NOT NULL,
    event_date DATE NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_fb_ads_campaign ON raw_fb_ads(campaign_id);
CREATE INDEX IF NOT EXISTS idx_fb_ads_date ON raw_fb_ads(event_date);

CREATE INDEX IF NOT EXISTS idx_google_ads_campaign ON raw_google_ads(campaign_id);
CREATE INDEX IF NOT EXISTS idx_google_ads_date ON raw_google_ads(event_date);

CREATE INDEX IF NOT EXISTS idx_tiktok_ads_campaign ON raw_tiktok_ads(campaign_id);
CREATE INDEX IF NOT EXISTS idx_tiktok_ads_date ON raw_tiktok_ads(event_date);

CREATE INDEX IF NOT EXISTS idx_linkedin_ads_campaign ON raw_linkedin_ads(campaign_id);
CREATE INDEX IF NOT EXISTS idx_linkedin_ads_date ON raw_linkedin_ads(event_date);

CREATE INDEX IF NOT EXISTS idx_ga4_user ON raw_ga4_sessions(user_uid);
CREATE INDEX IF NOT EXISTS idx_ga4_date ON raw_ga4_sessions(event_date);

CREATE INDEX IF NOT EXISTS idx_segment_user ON raw_segment_events(user_uid);
CREATE INDEX IF NOT EXISTS idx_segment_date ON raw_segment_events(event_date);

CREATE INDEX IF NOT EXISTS idx_mixpanel_user ON raw_mixpanel_events(user_uid);
CREATE INDEX IF NOT EXISTS idx_mixpanel_date ON raw_mixpanel_events(event_date);

CREATE INDEX IF NOT EXISTS idx_hubspot_user ON raw_hubspot_leads(user_uid);
CREATE INDEX IF NOT EXISTS idx_hubspot_campaign ON raw_hubspot_leads(campaign_id);
CREATE INDEX IF NOT EXISTS idx_hubspot_date ON raw_hubspot_leads(event_date);

CREATE INDEX IF NOT EXISTS idx_intercom_user ON raw_intercom_leads(user_uid);
CREATE INDEX IF NOT EXISTS idx_intercom_email ON raw_intercom_leads(email);
CREATE INDEX IF NOT EXISTS idx_intercom_date ON raw_intercom_leads(event_date);

CREATE INDEX IF NOT EXISTS idx_stripe_user ON raw_stripe_invoices(user_uid);
CREATE INDEX IF NOT EXISTS idx_stripe_date ON raw_stripe_invoices(event_date);

-- Success message
SELECT 'Clean database schema created successfully!' as status; 