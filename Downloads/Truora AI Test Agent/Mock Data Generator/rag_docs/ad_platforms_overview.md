# RAG Document: Ad Platforms Overview

## 1. High-Level Gist

This document provides a general overview of the four "Ad Platform" datasets in this project:
- `raw_fb_ads.csv`
- `raw_google_ads.csv`
- `raw_tiktok_ads.csv`
- `raw_linkedin_ads.csv`

These files contain mock data simulating daily performance metrics from digital advertising campaigns, such as cost, impressions, and clicks. They are the primary source of marketing spend and top-of-funnel performance metrics.

**Core Purpose**: To provide data for analyzing advertising effectiveness, calculating cost per acquisition (CPA), and understanding which campaigns are driving traffic.

**Agent's Goal**: The primary task for an AI agent is to ingest, unify, and analyze these disparate files. The agent must handle variations in column names, data formats, and currencies to create a single, cohesive view of advertising performance.

## 2. Shared Key Concepts & Columns

Across all ad platforms, several key concepts are central. While the specific names and formats may change in the "realistic" data, the underlying meaning is consistent.

### `campaign_id`
- **What it is**: A unique identifier for a specific marketing campaign.
- **Role**: This is the most important **foreign key**. It links ad spend data to lead generation data (e.g., `raw_hubspot_leads.csv`) and potentially to user activity (e.g., `raw_ga4_sessions.csv`).
- **Clean Data**: Always present, named `campaign_id`.
- **Realistic Data**: May have different casings (e.g., `campaignId`). It is the primary field for joining ad data to other datasets.

### `event_date` (or equivalent)
- **What it is**: The date on which the ad performance metrics were recorded. It represents a single day of activity.
- **Role**: The primary time-series field. Essential for trend analysis, cohorting, and joining data by date.
- **Clean Data**: Standard ISO-8601 format (`YYYY-MM-DD`). Named `event_date`.
- **Realistic Data**: Can appear in multiple formats (e.g., `MM/DD/YYYY`, `YYYY-MM-DDTHH:MM:SSZ`, Unix timestamp). The agent must be able to parse and normalize these different date/time formats.

### `cost` (or equivalent)
- **What it is**: The amount of money spent on a campaign for a given day.
- **Role**: The core financial metric. Used to calculate return on ad spend (ROAS) and CPA.
- **Clean Data**: Always in USD, named `cost_usd`, formatted as a standard decimal.
- **Realistic Data**: Can have various names (`spend`, `cost_local`). Crucially, it may be in different currencies (USD, COP, MXN) and require currency conversion. It may also have non-standard formatting (e.g., thousands separators like `1.500,23`).

### `clicks` & `impressions`
- **What they are**:
    - **Impressions**: The number of times an ad was shown.
    - **Clicks**: The number of times an ad was clicked.
- **Role**: Core performance metrics used to calculate Click-Through Rate (CTR = Clicks / Impressions).
- **Clean Data**: Standard integer format.
- **Realistic Data**: Column names may have different cases (`Clicks`, `impressionsCount`). Data may contain non-numeric values (e.g., `'--'`) or be missing, requiring cleaning and imputation.

## 3. Data Generation Logic (`make_data.py`)

The foundational "clean" data for all ad platforms is generated using the `build_ads()` function in `generator/make_data.py`.

- **Volume**: The script generates **1,800 rows** for each of the four ad platforms. This is calculated as `90 * len(campaign_ids)`, where there are 20 campaigns.
- **Campaigns**: A list of 20 unique `campaign_ids` is created at the start of the script. Each row is randomly assigned one of these IDs.
- **Dates**: Each row is assigned a random date between `2025-05-17` and `2025-06-16`.
- **Spend (`cost_usd`)**: The core financial metric, `spend`, is generated using a normal distribution: `abs(np.random.normal(75, 30))`. This creates a realistic distribution of daily ad spends, centered around $75.
- **Impressions & Clicks**: These are derived directly from the `spend` to ensure they are correlated:
    - `impressions` = `spend * 40 + random_integer`
    - `clicks` = `spend * 1.2 + random_integer`
    This simulates a basic ad performance model where higher spend generally leads to more impressions and clicks.

## 4. Key Takeaways for AI Agent

- **Unification is Key**: The primary challenge is to unify these four files. The agent must prioritize creating a standardized schema.
- **Follow the `campaign_id`**: This is the thread that ties ad spend to downstream results.
- **Normalize Dates and Currencies**: Before any analysis can be done, dates and financial figures from the "realistic" data must be converted to a standard format (e.g., `YYYY-MM-DD` and `USD`).
- **Consult Specific Docs**: While this document provides an overview, each ad platform has its own unique entropy and transformations. The agent should always consult the specific documentation for each file (e.g., `raw_fb_ads.md`) before processing it. 