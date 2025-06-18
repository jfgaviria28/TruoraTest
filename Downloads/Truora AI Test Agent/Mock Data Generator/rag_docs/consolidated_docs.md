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

# RAG Document: Web & Product Analytics Overview

## 1. High-Level Gist

This document provides a general overview of the three "Analytics Events" datasets in this project:
- `raw_ga4_sessions.csv`
- `raw_segment_events.csv`
- `raw_mixpanel_events.csv`

These files simulate data from web and product analytics platforms. Unlike the ad platforms, which focus on spend and high-level campaign metrics, these sources track user-level activity, such as page views, specific events (e.g., 'signup'), and user sessions.

**Core Purpose**: To provide a granular view of user behavior and link it back to the marketing campaigns that acquired them. This data is essential for understanding user journeys and conversion events.

**Agent's Goal**: The primary task for an AI agent is to ingest, standardize, and connect this user-level data to the higher-level ad platform data. The agent must handle variations in event schemas, naming conventions, and identifiers to build a complete picture of the user funnel.

## 2. Shared Key Concepts & Columns

These platforms track user interactions, so their schemas are built around users, sessions, and events.

### `user_uid` (or equivalent)
- **What it is**: A unique identifier for a single user across different sessions and platforms.
- **Role**: This is a critical **foreign key**. It's the primary means of linking a user's web activity (`GA4`) to their product activity (`Mixpanel`, `Segment`) and ultimately to their lead/customer profile (`HubSpot`, `Stripe`).
- **Clean Data**: Always present, named `user_uid`.
- **Realistic Data**: May have a different name (e.g., `uid` in Segment). Crucially, it may also be **missing** (`NULL`) for some events, representing anonymous or untracked users.

### `session_id` (or equivalent)
- **What it is**: A unique identifier for a single user visit or session. A user can have multiple sessions.
- **What it is used for**: It groups a series of events from a single visit. It can be linked to `campaign_id` to attribute a session to a marketing campaign.
- **Clean Data**: Standard `session_id`.
- **Realistic Data**: Naming can vary (`sessionId`). The format can be inconsistent, with some malformed IDs introduced in the entropy script.

### `event_date` (or equivalent)
- **What it is**: The date on which the user session or event occurred.
- **Role**: The primary time-series field for user activity.
- **Clean Data**: Standard ISO format (`YYYY-MM-DD`), named `date`.
- **Realistic Data**: Naming varies (`event_date`, `ts`). The format is generally consistent (`YYYY-MM-DD`), but the agent should always verify.

### Event-Specific Data
- **What it is**: These columns describe the specific action the user took.
- **Clean Data**: Varies by source, e.g., `conv_flag` in GA4, `event_name` in Mixpanel.
- **Realistic Data**: The structure and naming can be very different. Segment, for example, uses a `properties_json` blob to store event details, requiring the agent to parse JSON.

## 3. Data Generation Logic (`make_data.py`)

The clean data for these platforms is generated by the `build_sessions()` function in `generator/make_data.py`.

- **Volume**: The script generates **24,000 rows** for each of the three analytics platforms.
- **User and Session IDs**: Both `user_uid` and `session_id` are generated using `uuid.uuid4().hex[:10]`, creating random, unique identifiers.
- **Campaign Attribution**: Each session is randomly associated with a `campaign_id`, simulating how an analytics platform would attribute a user's visit to a marketing campaign.
- **Event Variation**: The function has conditional logic to create different schemas for each source, simulating the different ways these platforms structure their data (e.g., `event_name` vs. `event_json`).

## 4. Key Takeaways for AI Agent

- **User-Centric View**: The agent's focus should shift from a campaign-centric view (ad platforms) to a user-centric view. The `user_uid` is the most important identifier in these files.
- **Schema Unification is a Major Challenge**: Unlike the ad platforms, the schemas here are fundamentally different. The agent will need to perform significant transformation to create a unified "events" table. For example, it will need to parse the `properties_json` from Segment to extract a consistent event type.
- **Handle Missing `user_uid`**: The presence of `NULL` user IDs is a key feature of the realistic data. The agent must decide on a strategy for handling these anonymous events (e.g., keep them for aggregate analysis or filter them out for user-level joins).
- **Consult Specific Docs**: This overview provides the general context, but the agent MUST consult the specific RAG documents for `raw_ga4_sessions.md`, `raw_segment_events.md`, and `raw_mixpanel_events.md` to understand their unique entropy and cleaning requirements. 

# RAG Document: Leads & Revenue Overview

## 1. High-Level Gist

This document provides a general overview of the three "Leads & Revenue" datasets, which represent the final stages of the customer journey:
- `raw_hubspot_leads.csv`
- `raw_intercom_leads.csv`
- `raw_stripe_invoices.csv`

These files simulate data from CRM (Customer Relationship Management) and payment processing systems. They move beyond anonymous user activity (Analytics Events) to track identified leads and, ultimately, revenue-generating customers.

**Core Purpose**: To connect marketing efforts (`campaign_id`) and user activity (`user_uid`) to tangible business outcomes like qualified leads and financial transactions. This is where Return on Ad Spend (ROAS) is calculated.

**Agent's Goal**: The agent's primary task is to clean and unify this data to create a complete customer profile. It must handle duplicate leads, inconsistent data, and key mismatches to accurately attribute revenue back to the original marketing campaigns.

## 2. Shared Key Concepts & Columns

These platforms track identified leads and customers, so their schemas are built around lead status and financial value.

### `user_uid`
- **What it is**: The unique user identifier that links back to the analytics data.
- **Role**: This is the **most important foreign key** in this group. It is the thread that connects a paying customer in `Stripe` back to their session in `GA4` and the ad they clicked in `Facebook Ads`.

### `lead_id` / `invoice_id`
- **What it is**: The primary key for each respective file, identifying a specific lead or invoice.
- **Role**: Uniquely identifies each record within its own source.

### `status`
- **What it is**: Describes the current stage of a lead or invoice.
- **Role**: Essential for funnel analysis (e.g., how many "New" leads become "Qualified"?) and for data filtering (e.g., only analyze "paid" invoices).
- **Clean Data**: Contains clear, consistent values (`New`, `Contacted`, `Qualified`).
- **Realistic Data**: Can contain ambiguous values like `'UNKNOWN'` or be inconsistent across platforms.

### `deal_amount` / `amount`
- **What it is**: The financial value associated with a lead or transaction.
- **Role**: The core metric for calculating revenue and ROAS.
- **Clean Data**: Standard decimal format.
- **Realistic Data**: Can contain non-numeric values like `'N/A'`, requiring cleaning.

## 3. Data Generation Logic (`make_data.py`)

The data for these platforms is generated sequentially at the end of `make_data.py`.

- **`HubSpot` / `Intercom` Leads**:
    - **Volume**: **3,000 lead records** are generated for each platform.
    - **Logic**: A loop creates users, randomly assigns them a `campaign_id`, and gives them a status (`New`, `Contacted`, `Qualified`). A potential `deal_amount` is also generated. The exact same lead data is used as the base for both HubSpot and Intercom before entropy is added.
- **`Stripe` Invoices**:
    - **Volume**: Invoice records are **not** generated independently. They are created **only for leads who have a `status` of "Qualified"**. This creates a logical funnel where only a subset of leads become paying customers.
    - **Logic**: The script iterates through the generated leads and, if a lead is "Qualified," it creates a corresponding invoice record, linking it via `user_uid`. The invoice amount is based on the lead's `deal_amount`.

## 4. Key Takeaways for AI Agent

- **This is the Bottom of the Funnel**: This data represents the ultimate goal of the marketing spend. The agent's analysis should often culminate here.
- **Follow the `user_uid`**: The agent must perform joins upstream using `user_uid` to connect revenue back to user behavior and ad campaigns.
- **Deduplication is a Key Challenge**: The realistic data for Intercom contains duplicate leads. The agent must be able to identify and merge these duplicates to avoid over-counting leads.
- **Attribute Revenue Carefully**: The `raw_stripe_invoices.csv` file in the realistic dataset is intentionally missing `campaign_id`. The agent cannot join it directly to ad platform data. It **must** perform a multi-step join: `Stripe -> Leads -> Analytics -> Ads` using `user_uid` and `campaign_id` as the linking keys.
- **Consult Specific Docs**: Each of these files has significant, unique entropy. The agent must consult the specific RAG documents for each file before processing. 

# RAG Document: `raw_fb_ads.csv`

## 1. Source Description & Gist

- **File Name**: `raw_fb_ads.csv`
- **Data Source**: Simulates daily advertising performance data from **Facebook Ads**.
- **High-Level Purpose**: This file tracks how much is being spent on Facebook campaigns and what performance (impressions, clicks) that spend is generating. It is a critical input for calculating Return On Ad Spend (ROAS) and attributing customer acquisition to specific campaigns.
- **Agent's Primary Goal**: To correctly ingest this data, accounting for its specific "realistic" quirks, and unify it with data from other ad platforms. The key challenge is handling rows where `cost_usd` is missing and must be calculated from `cost_per_click`.

## 2. File Structure & Schema

### Clean Data Profile

When generated in "clean" mode, the file has a simple, consistent structure.

- **Location**: `data/raw_fb_ads.csv`
- **Schema**:
    - `event_date`: `DATE`, The day the metrics were recorded (e.g., `2025-05-17`).
    - `campaign_id`: `TEXT`, The unique identifier for the campaign (e.g., `CID_a1b2c3`). This is the primary key for joining with other datasets.
    - `cost_usd`: `DECIMAL`, The total amount spent in USD for that day.
    - `impressions`: `INTEGER`, The total number of times the ad was shown.
    - `clicks`: `INTEGER`, The total number of times the ad was clicked.

- **Generation Logic (`make_data.py`)**:
    - The file contains **1,800 rows** of data.
    - `cost_usd` is generated from a normal distribution (`mean=75`, `std=30`), ensuring realistic spend variation.
    - `impressions` and `clicks` are mathematically derived from `cost_usd` to ensure a logical correlation (more spend = more clicks/impressions).

### Realistic Data Profile (with Entropy)

When generated in "realistic" mode (by running `make_realistic_data.py`), the `add_entropy.py` script applies a specific transformation to this file to introduce real-world messiness.

- **Key Transformation**: For **15% of the rows**, the script simulates a common reporting variation where total cost is not provided, but cost-per-click (CPC) is.
    - A new column, `cost_per_click`, is added.
    - For a random 15% of rows:
        1. The value in `cost_usd` is **removed** (it becomes an empty string `''`).
        2. The `cost_per_click` column is populated by calculating `cost_usd / clicks`.

- **Resulting Realistic Schema**:
    - `event_date`: `DATE`
    - `campaign_id`: `TEXT`
    - `cost_usd`: `TEXT` (data type changes to accommodate empty strings)
    - `impressions`: `INTEGER`
    - `clicks`: `INTEGER`
    - `cost_per_click`: `DECIMAL` (contains nulls for 85% of rows)

- **Example of Realistic Data**:

  | event_date | campaign_id | cost_usd | impressions | clicks | cost_per_click |
  |------------|-------------|----------|-------------|--------|----------------|
  | 2025-05-20 | CID_f9e8d7  | 85.34    | 3463        | 108    |                |
  | 2025-05-21 | CID_a1b2c3  |          | 2541        | 75     | 1.25           |
  | 2025-05-22 | CID_c4d5e6  | 102.11   | 4188        | 128    |                |

## 3. Key Challenges & Instructions for AI Agent

1.  **Cost Unification is Priority #1**: The most critical task is to create a single, unified cost column. The agent MUST detect when `cost_usd` is null or empty.
2.  **Imputing `cost_usd`**: When `cost_usd` is missing, it must be calculated using the other available metrics. The formula is:
    ```
    cost_usd = clicks * cost_per_click
    ```
    The agent should perform this calculation to fill in the missing `cost_usd` values *before* attempting any aggregation or analysis.
3.  **Data Type Management**: The agent must be aware that the `cost_usd` column in the raw realistic CSV is of type `TEXT` or `OBJECT` due to the empty strings. After imputation, it should be converted to a `DECIMAL` or `FLOAT` data type for calculations.
4.  **Final Schema**: After cleaning, the agent should aim to have a unified schema that matches the "clean" profile (i.e., drop the `cost_per_click` column after it has been used for imputation). The target columns for analysis should be: `event_date`, `campaign_id`, `cost_usd`, `impressions`, `clicks`.
5.  **No Other Entropy**: This file is only affected by the cost imputation challenge. It does not have currency variations, major column name changes, or date format issues like other ad platform files. The agent should consult the specific docs for other files to see their unique challenges. 

# RAG Document: `raw_ga4_sessions.csv`

## 1. Source Description & Gist

- **File Name**: `raw_ga4_sessions.csv`
- **Data Source**: Simulates user session data from **Google Analytics 4 (GA4)**.
- **High-Level Purpose**: This file represents typical web analytics data, tracking user sessions and attributing them to marketing campaigns. It serves as the top of the user behavior funnel, showing which campaigns are successfully driving users to the website.
- **Agent's Primary Goal**: To ingest this data, clean up its specific entropy (column names and malformed IDs), and use it as a bridge between high-level ad spend and more granular user events.

## 2. File Structure & Schema

### Clean Data Profile

In "clean" mode, the file is generated with a schema focused on sessions and conversions.

- **Location**: `data/raw_ga4_sessions.csv`
- **Schema**:
    - `date`: `DATE` (`YYYY-MM-DD`).
    - `session_id`: `TEXT`, A unique identifier for the user session.
    - `user_uid`: `TEXT`, A unique identifier for the user.
    - `campaign_id`: `TEXT`, The campaign that drove the session.
    - `conv_flag`: `INTEGER` (`0` or `1`), A flag indicating if a conversion occurred during the session.
- **Generation Logic**: The file contains **24,000 rows** generated by the `build_sessions()` function. The `conv_flag` is set to `1` with a 10% probability, simulating a 10% session conversion rate.

### Realistic Data Profile (with Entropy)

The `add_entropy.py` script applies two main transformations to this file.

- **Key Transformations**:
    1.  **Column Name Convention**: `date` is renamed to `event_date` and `session_id` is renamed to `sessionId` (camelCase).
    2.  **Malformed Session IDs**: For a random **3% of rows**, the `sessionId` is intentionally corrupted to simulate data quality issues. The corruption logic replaces the last 3 characters with the string `"_BAD"`.

- **Resulting Realistic Schema**:
    - `event_date`: `TEXT` (`YYYY-MM-DD` format).
    - `sessionId`: `TEXT` (Can contain malformed values).
    - `user_uid`: `TEXT`
    - `campaign_id`: `TEXT`
    - `conv_flag`: `INTEGER`

- **Example of Realistic Data**:

  | event_date | sessionId      | user_uid   | campaign_id | conv_flag |
  |------------|----------------|------------|-------------|-----------|
  | 2025-05-20 | abcdef1234     | user_a     | CID_f9e8d7  | 0         |
  | 2025-05-21 | bcdefg_BAD     | user_b     | CID_a1b2c3  | 1         |
  | 2025-05-22 | cdefgh4567     | user_c     | CID_c4d5e6  | 0         |

## 3. Key Challenges & Instructions for AI Agent

1.  **Column Name Mapping**: The agent must first map the column names to the standard internal schema.
    - `event_date` → `event_date`
    - `sessionId` → `session_id`
    - `user_uid` → `user_uid`
    - `campaign_id` → `campaign_id`
    - `conv_flag` → `is_conversion` (A more descriptive standard name).
2.  **Data Validation and Cleaning**: The agent's most important task for this file is to handle the `malformed` session IDs.
    - **Detection**: The agent should validate the `session_id` column. A simple rule could be to check the length of the ID or look for the `"_BAD"` suffix.
    - **Strategy**: The agent needs a strategy for these rows. Options include:
        - **Filtering**: Remove the rows with bad session IDs. This is the safest option if the session ID is critical for joins.
        - **Flagging**: Keep the rows but add a separate boolean column (e.g., `is_malformed_session`) to flag them for exclusion from certain analyses.
        - **Attempted Repair**: This is advanced, but an agent could attempt to repair the ID if a pattern is known (not possible here, as the original characters are lost).
    - For this dataset, **filtering** is the recommended approach.
3.  **Unification**: Once cleaned, this data serves as a key link. The `campaign_id` can be joined to the ad platforms' data, and the `user_uid` can be joined to the other analytics and CRM data. 

# RAG Document: `raw_google_ads.csv`

## 1. Source Description & Gist

- **File Name**: `raw_google_ads.csv`
- **Data Source**: Simulates daily advertising performance data from **Google Ads**.
- **High-Level Purpose**: This file tracks daily spend and performance for search advertising campaigns. It's essential for understanding which campaigns are driving clicks from Google Search and for calculating the effectiveness of those campaigns.
- **Agent's Primary Goal**: To ingest and clean this data, paying special attention to its unique date format, column naming convention, and non-standard null values. The agent must standardize this data before it can be unified with other ad platform data.

## 2. File Structure & Schema

### Clean Data Profile

In "clean" mode, the file schema is consistent with the other ad platforms.

- **Location**: `data/raw_google_ads.csv`
- **Schema**:
    - `event_date`: `DATE`, Standard ISO format (`YYYY-MM-DD`).
    - `campaign_id`: `TEXT`, Standard snake_case name.
    - `cost_usd`: `DECIMAL`, Standard name and USD currency.
    - `impressions`: `INTEGER`
    - `clicks`: `INTEGER`

- **Generation Logic**: The base data is generated by the same `build_ads()` function as the other platforms, containing **1,800 rows** with logically correlated metrics.

### Realistic Data Profile (with Entropy)

When generated in "realistic" mode, `add_entropy.py` applies several transformations to make the data more challenging to process.

- **Key Transformations**:
    1.  **Date Format Change**: The `date` column is converted from the standard `YYYY-MM-DD` to the US-specific `MM/DD/YYYY` format.
    2.  **Column Name Convention**: Columns are renamed to `camelCase`.
        - `campaign_id` → `campaignId`
        - `cost_usd` → `spend`
        - `date` → `date` (name remains but format changes)
    3.  **Non-Standard Nulls**: For a random **4% of rows**, the `clicks` value is replaced with the string `'--'`, simulating a common issue in exported reports where low-performance metrics are represented as dashes.

- **Resulting Realistic Schema**:
    - `date`: `TEXT`, Contains dates in `MM/DD/YYYY` format.
    - `campaignId`: `TEXT`
    - `spend`: `DECIMAL`
    - `impressions`: `INTEGER`
    - `clicks`: `TEXT` (data type changes to accommodate `'--'`)

- **Example of Realistic Data**:

  | date       | campaignId | spend  | impressions | clicks |
  |------------|------------|--------|-------------|--------|
  | 05/20/2025 | CID_f9e8d7 | 85.34  | 3463        | 108    |
  | 05/21/2025 | CID_a1b2c3 | 93.75  | 2541        | --     |
  | 05/22/2025 | CID_c4d5e6 | 102.11 | 4188        | 128    |

## 3. Key Challenges & Instructions for AI Agent

1.  **Column Name Mapping**: The agent's first step must be to map the realistic column names back to the standard, internal schema.
    - `date` → `event_date`
    - `campaignId` → `campaign_id`
    - `spend` → `cost_usd`
    - `impressions` → `impressions`
    - `clicks` → `clicks`
2.  **Date Parsing**: The agent must recognize the `MM/DD/YYYY` format in the `event_date` column and parse it correctly, converting it to the standard `YYYY-MM-DD` format for unification with other data sources. Standard date parsing libraries should handle this automatically if the format is identified.
3.  **Handling Non-Standard Nulls**: The agent must scan the `clicks` column for non-numeric values like `'--'`. These should be treated as `NULL` or `0`. After cleaning, the column's data type should be converted from `TEXT`/`OBJECT` to `INTEGER`. A safe approach is to replace `'--'` with `0` or `NULL` and then cast the column.
4.  **No Currency or Major Schema Issues**: Unlike other sources, this file is consistently in USD and does not have complex structural changes like the `cost_per_click` issue in the Facebook data. The primary challenges are formatting and naming conventions.
5.  **Final Schema**: After cleaning and standardization, the resulting data frame should have the standard columns (`event_date`, `campaign_id`, `cost_usd`, `impressions`, `clicks`) and data types, making it ready for unification. 

# RAG Document: `raw_hubspot_leads.csv`

## 1. Source Description & Gist

- **File Name**: `raw_hubspot_leads.csv`
- **Data Source**: Simulates lead data from a CRM like **HubSpot**.
- **High-Level Purpose**: This file tracks potential customers, their status in the sales funnel, and their potential deal value. It is a core component for measuring the quality of leads generated by marketing campaigns.
- **Agent's Primary Goal**: To ingest and clean this data, specifically handling non-standard values in both categorical (`status`) and numeric (`deal_amount`) fields. The agent must standardize these fields before the data can be used for analysis or joined with other sources.

## 2. File Structure & Schema

### Clean Data Profile

- **Location**: `data/raw_hubspot_leads.csv`
- **Schema**:
    - `lead_id`: `TEXT`, The unique identifier for the lead.
    - `user_uid`: `TEXT`, The user identifier for joining with analytics data.
    - `campaign_id`: `TEXT`, The campaign that generated the lead.
    - `status`: `TEXT`, The lead's status (e.g., "New", "Contacted", "Qualified").
    - `deal_amount`: `DECIMAL`, The potential value of the lead.
- **Generation Logic**: A base of **3,000 lead records** is generated. The `status` is chosen randomly, and a `deal_amount` is generated from an exponential distribution.

### Realistic Data Profile (with Entropy)

The `add_entropy.py` script introduces data quality issues to test the agent's cleaning capabilities.

- **Key Transformations**:
    1.  **Unknown Statuses**: For a random **8% of rows**, the `status` is replaced with the string `'UNKNOWN'`, representing ambiguous or improperly categorized leads.
    2.  **Missing Numeric Values**: For a random **3% of rows**, the `deal_amount` is replaced with the string `'N/A'`, simulating exports where numeric data is missing and represented as text.

- **Resulting Realistic Schema**:
    - `lead_id`: `TEXT`
    - `user_uid`: `TEXT`
    - `campaign_id`: `TEXT`
    - `status`: `TEXT` (can contain 'UNKNOWN').
    - `deal_amount`: `TEXT` (data type changes to accommodate `'N/A'`).

- **Example of Realistic Data**:

  | lead_id  | user_uid | campaign_id | status    | deal_amount |
  |----------|----------|-------------|-----------|-------------|
  | lead_abc | user_a   | CID_f9e8d7  | Qualified | 500.25      |
  | lead_def | user_b   | CID_a1b2c3  | UNKNOWN   | 250.75      |
  | lead_ghi | user_c   | CID_c4d5e6  | New       | N/A         |

## 3. Key Challenges & Instructions for AI Agent

1.  **Standardize `status` Column**: The agent needs a strategy for the `'UNKNOWN'` statuses.
    - **Detection**: Identify all rows where `status = 'UNKNOWN'`.
    - **Strategy**: The appropriate action depends on the analysis.
        - **Filtering**: For a strict funnel analysis, the agent might filter these records out.
        - **Re-categorization**: A more advanced agent could potentially re-categorize them based on other user activity, but for this dataset, treating them as a distinct category or filtering them is sufficient.
        - **Default**: Treat `'UNKNOWN'` as a valid, separate status category for reporting.
2.  **Clean and Cast `deal_amount` (Critical Path)**: The agent must handle the `'N/A'` values in the `deal_amount` column.
    - **Detection**: Identify all rows where `deal_amount` is not a valid number.
    - **Imputation**: Replace `'N/A'` with a numeric value. `0` is a safe and standard choice, as it will not affect financial sums. `NULL` is also an acceptable choice.
    - **Type Conversion**: After cleaning, the agent MUST cast the entire `deal_amount` column from `TEXT`/`OBJECT` to a `DECIMAL` or `FLOAT` type. Failure to do this will cause errors in any downstream calculations.
3.  **No Deduplication Needed**: Unlike the Intercom data, this file does not have a duplicate record problem. The agent should focus solely on the column-level data quality issues. 

# RAG Document: `raw_intercom_leads.csv`

## 1. Source Description & Gist

- **File Name**: `raw_intercom_leads.csv`
- **Data Source**: Simulates lead data from a customer communication platform like **Intercom**.
- **High-Level Purpose**: This file tracks leads captured through communication channels (e.g., website chat). It serves a similar purpose to the HubSpot data but is designed to present a different, critical data quality challenge: duplicates.
- **Agent's Primary Goal**: To ingest this data and perform **deduplication**. The agent must identify and merge or remove duplicate lead records based on fuzzy matching of email addresses to avoid over-counting leads and to create a clean customer list.

## 2. File Structure & Schema

### Clean Data Profile

The base data for Intercom is identical to the HubSpot base data.

- **Location**: `data/raw_intercom_leads.csv`
- **Schema (before entropy)**:
    - `lead_id`, `user_uid`, `campaign_id`, `status`, `deal_amount`.
- **Generation Logic**: Starts with the same **3,000 lead records** as HubSpot.

### Realistic Data Profile (with Entropy)

The `add_entropy.py` script applies a series of transformations focused on creating a deduplication challenge.

- **Key Transformations**:
    1.  **Email Column Creation**: An `email` column is added, programmatically created based on the `user_uid` (e.g., `user_{user_uid}@company.com`).
    2.  **Duplicate Record Generation**: **2% of the rows (60 records)** are randomly selected and duplicated.
    3.  **Email Typo Introduction**: In the duplicated rows, a typo is intentionally introduced into the `email` address. The script randomly applies one of four common typo patterns:
        - `user@company.com` → `user@gcompany.com` (extra character)
        - `user@company.com` → `user@company.co` (missing character)
        - `user_@company.com` → `user.@company.com` (character substitution)
        - `user@company.com` → `user@compamy.com` (character transposition)
    4.  **Minor Field Modification**: To make the duplicates less obvious, the `lead_id` and `deal_amount` in the duplicated rows are also slightly modified.

- **Resulting Realistic Schema**:
    - `lead_id`, `user_uid`, `campaign_id`, `status`, `deal_amount`, `email`.
    - Total rows = 3000 (original) + 60 (duplicates) = **3060 rows**.

- **Example of Realistic Data**:

  | lead_id   | user_uid | email                   | status    |
  |-----------|----------|-------------------------|-----------|
  | lead_xyz  | user_x   | user_x@company.com      | Qualified |
  | ...       | ...      | ...                     | ...       |
  | lead_xya  | user_x   | user_x@compamy.com      | Qualified |

## 3. Key Challenges & Instructions for AI Agent

1.  **Deduplication (Critical Path)**: The agent's primary task is to identify and handle the 60 duplicate records.
    - **Simple Keying Fails**: The agent cannot simply use `email` or `lead_id` as a unique key, because these have been modified in the duplicates.
    - **Fuzzy Matching**: The agent must use a more sophisticated approach. The `user_uid` is the most reliable key for identifying duplicates in this dataset, as it remains consistent between the original and the duplicate record. A good strategy would be to group records by `user_uid` and then, for any group with more than one record, implement a merging strategy.
    - **Merging Strategy**: Once duplicates are identified, the agent needs to merge them into a single record. A common strategy is to:
        - Keep the earliest `lead_id`.
        - Keep the most "correct" email (e.g., the one that matches the `user_uid` pattern).
        - Average or take the max of the `deal_amount`.
        - For this dataset, simply identifying duplicates by `user_uid` and selecting one of the records (e.g., the first one) is a sufficient strategy.
2.  **Email Cleaning**: As part of the deduplication, the agent may need to clean the email addresses. The typos are subtle and designed to test fuzzy matching logic.
3.  **Final Schema**: After deduplication, the agent should have a clean set of 3,000 unique leads, ready for analysis. 

# RAG Document: `raw_linkedin_ads.csv`

## 1. Source Description & Gist

- **File Name**: `raw_linkedin_ads.csv`
- **Data Source**: Simulates daily advertising performance from **LinkedIn Ads**.
- **High-Level Purpose**: This file provides daily spend and performance metrics for professional, B2B-focused campaigns run on LinkedIn. It is a key source for understanding ad effectiveness in a corporate context.
- **Agent's Primary Goal**: To ingest this data, with a primary focus on correctly parsing its unique, timezone-aware timestamp format and unifying it with the other ad platform sources.

## 2. File Structure & Schema

### Clean Data Profile

In "clean" mode, the file adheres to the standard ad platform schema.

- **Location**: `data/raw_linkedin_ads.csv`
- **Schema**:
    - `event_date`: `DATE` (`YYYY-MM-DD`).
    - `campaign_id`: `TEXT`
    - `cost_usd`: `DECIMAL`
    - `impressions`: `INTEGER`
    - `clicks`: `INTEGER`
- **Generation Logic**: The file contains **1,800 rows**, generated by the standard `build_ads()` function.

### Realistic Data Profile (with Entropy)

The `add_entropy.py` script applies one specific, important transformation to this file.

- **Key Transformation**:
    1.  **Date Format Change to Timezone-Aware Timestamp**: The `date` column is converted from a simple date (`YYYY-MM-DD`) into a full, timezone-aware ISO 8601 timestamp string. A random time is added to each date, and a fixed timezone (`-05:00`, corresponding to US Eastern Time) is appended.

- **Resulting Realistic Schema**:
    - `date`: `TEXT`, Contains timestamps in `YYYY-MM-DDTHH:MM:SS-05:00` format.
    - `campaign_id`: `TEXT`
    - `cost_usd`: `DECIMAL`
    - `impressions`: `INTEGER`
    - `clicks`: `INTEGER`

- **Example of Realistic Data**:

  | date                        | campaign_id | cost_usd | impressions | clicks |
  |-----------------------------|-------------|----------|-------------|--------|
  | 2025-05-20T14:23:15-05:00   | CID_f9e8d7  | 85.34    | 3463        | 108    |
  | 2025-05-21T08:11:52-05:00   | CID_a1b2c3  | 93.75    | 2541        | 75     |

## 3. Key Challenges & Instructions for AI Agent

1.  **Date/Time Parsing**: The agent's primary task for this file is to correctly handle the timestamp format.
    - It must parse the full `YYYY-MM-DDTHH:MM:SS-05:00` string.
    - For unification with other ad platform data, the agent should **truncate** the timestamp to just the date part (`YYYY-MM-DD`). The time and timezone information should be discarded to align with the daily aggregation level of the other sources.
2.  **Column Name Standardization**: Although minor, the agent should ensure the `date` column is renamed to the standard `event_date` for consistency.
    - `date` → `event_date`
3.  **No Other Entropy**: This file has no currency issues, no major column name changes (other than `date`), and no missing data challenges. The focus is exclusively on date/time normalization.
4.  **Final Schema**: After parsing the date and renaming the column, the data will conform to the standard ad platform schema (`event_date`, `campaign_id`, `cost_usd`, `impressions`, `clicks`) and will be ready for unification. 

# RAG Document: `raw_mixpanel_events.csv`

## 1. Source Description & Gist

- **File Name**: `raw_mixpanel_events.csv`
- **Data Source**: Simulates event data from a product analytics platform like **Mixpanel**.
- **High-Level Purpose**: This file provides granular data on specific actions users take within a product (e.g., 'signup', 'purchase'). It is used to understand user engagement and conversion at a detailed level.
- **Agent's Primary Goal**: To ingest this data, standardize its schema, and handle the presence of anonymous events (null `user_uid`). It must be unified with other event streams like Segment to create a complete picture of user actions.

## 2. File Structure & Schema

### Clean Data Profile

The `build_sessions()` function in `make_data.py` generates a specific schema for Mixpanel, different from GA4 and Segment.

- **Location**: `data/raw_mixpanel_events.csv`
- **Schema**:
    - `date`: `DATE` (`YYYY-MM-DD`).
    - `user_uid`: `TEXT`, The unique user identifier.
    - `event_name`: `TEXT`, A string describing the event (e.g., "page_view", "click", "signup", "purchase").
    - `campaign_id`: `TEXT`, The campaign that originally acquired the user.
- **Generation Logic**: The file contains **24,000 rows**. The `event_name` is chosen randomly from a list of four possible actions, simulating a simple product funnel.

### Realistic Data Profile (with Entropy)

The `add_entropy.py` script applies one critical transformation to introduce the concept of anonymous users.

- **Key Transformation**:
    1.  **Null `user_uid`**: For a random **5% of rows**, the `user_uid` is replaced with a `NULL` (or `NaN`) value. This simulates events from users who are not logged in or cannot be identified.

- **Resulting Realistic Schema**:
    - `date`: `TEXT` (`YYYY-MM-DD` format).
    - `user_uid`: `TEXT` (can contain nulls).
    - `event_name`: `TEXT`
    - `campaign_id`: `TEXT`

- **Example of Realistic Data**:

  | date       | user_uid   | event_name | campaign_id |
  |------------|------------|------------|-------------|
  | 2025-05-20 | user_a     | page_view  | CID_f9e8d7  |
  | 2025-05-21 |            | signup     | CID_a1b2c3  |
  | 2025-05-22 | user_c     | purchase   | CID_c4d5e6  |

## 3. Key Challenges & Instructions for AI Agent

1.  **Column Name Standardization**: The agent should first ensure column names align with the internal standard.
    - `date` → `event_date`
    - `user_uid` → `user_uid`
    - `event_name` → `event_type` (to align with the standardized column created from Segment data).
    - `campaign_id` → `campaign_id`
2.  **Handling Null `user_uid` (Critical Path)**: The most important task is for the agent to have a clear strategy for handling rows where `user_uid` is null.
    - **Detection**: The agent must identify rows with null `user_uid`.
    - **Strategy**: This is a business logic decision. The agent should consider the implications:
        - **User-level analysis**: For any analysis that requires tracking a user's journey (e.g., joins with `Stripe` or `HubSpot` data), these anonymous events **must be filtered out**.
        - **Aggregate analysis**: For analyses that don't require user-level tracking (e.g., "How many 'signup' events occurred yesterday?"), these anonymous events can and **should be included**.
    - The agent should be capable of both filtering and including these events based on the analytical task. A good default is to keep them but be aware they will not join to user-specific data.
3.  **Schema Unification**: The target schema for this file is `event_date`, `user_uid`, `campaign_id`, and `event_type`. This makes it directly compatible for concatenation with the cleaned data from `raw_segment_events.csv`, allowing the creation of a single, comprehensive user events table. 

# RAG Document: `raw_segment_events.csv`

## 1. Source Description & Gist

- **File Name**: `raw_segment_events.csv`
- **Data Source**: Simulates event stream data from a Customer Data Platform (CDP) like **Segment**.
- **High-Level Purpose**: This file represents a raw event stream, capturing every user interaction as a distinct event. Unlike session-based data (GA4), this source provides a more granular, action-oriented view of user behavior.
- **Agent's Primary Goal**: To parse this fundamentally different schema, extract key information from a JSON blob, and standardize it to be unified with other event data (like Mixpanel). This is a test of the agent's ability to handle nested data structures.

## 2. File Structure & Schema

### Clean Data Profile

The `build_sessions()` function in `make_data.py` has special logic for this source, creating a unique schema from the start.

- **Location**: `data/raw_segment_events.csv`
- **Schema**:
    - `date`: `DATE` (`YYYY-MM-DD`).
    - `session_id`: `TEXT`, A unique identifier for the user session.
    - `user_uid`: `TEXT`, A unique identifier for the user.
    - `campaign_id`: `TEXT`
    - `event_json`: `TEXT`, A string containing a JSON object with event details.
- **Generation Logic**: The file contains **24,000 rows**. The `event_json` field is populated with a simple JSON object like `{"event_type": "click"}` where the event type is one of "click", "view", or "conversion".

### Realistic Data Profile (with Entropy)

`add_entropy.py` applies a complete renaming of the columns to match common CDP conventions.

- **Key Transformation**:
    1.  **Column Renaming**: All columns are renamed to short, technical names.
        - `date` → `ts` (for timestamp)
        - `session_id` → `session_id` (no change)
        - `user_uid` → `uid`
        - `campaign_id` → `campaign_id` (no change)
        - `event_json` → `properties_json`

- **Resulting Realistic Schema**:
    - `ts`: `TEXT` (`YYYY-MM-DD` format).
    - `session_id`: `TEXT`
    - `uid`: `TEXT`
    - `campaign_id`: `TEXT`
    - `properties_json`: `TEXT` (A string containing a JSON object).

- **Example of Realistic Data**:

  | ts         | session_id | uid        | campaign_id | properties_json              |
  |------------|------------|------------|-------------|------------------------------|
  | 2025-05-20 | abcdef1234 | user_a     | CID_f9e8d7  | `{"event_type": "view"}`     |
  | 2025-05-21 | bcdefg5678 | user_b     | CID_a1b2c3  | `{"event_type": "click"}`    |
  | 2025-05-22 | cdefgh9012 | user_a     | CID_f9e8d7  | `{"event_type": "conversion"}` |

## 3. Key Challenges & Instructions for AI Agent

1.  **Column Name Mapping**: The agent must first map the technical names to the standard internal schema.
    - `ts` → `event_date`
    - `session_id` → `session_id`
    - `uid` → `user_uid`
    - `campaign_id` → `campaign_id`
    - `properties_json` → (This is not a direct mapping; it's a source for other columns).
2.  **JSON Parsing (Critical Path)**: The most important task is to parse the `properties_json` column.
    - The agent must treat this column as a JSON string.
    - It needs to extract the `event_type` key from the JSON object.
    - The extracted value should be placed in a new, standardized `event_type` column.
3.  **Schema Creation from Nested Data**: This file tests the agent's ability to create a new column (`event_type`) from a nested data structure, which is a common data engineering task.
4.  **Final Schema**: After renaming columns and parsing the JSON, the agent should produce a standardized event table. The `properties_json` column can be dropped after parsing. The target schema should be: `event_date`, `session_id`, `user_uid`, `campaign_id`, `event_type`. This makes it compatible for unification with Mixpanel data. 

# RAG Document: `raw_stripe_invoices.csv`

## 1. Source Description & Gist

- **File Name**: `raw_stripe_invoices.csv`
- **Data Source**: Simulates invoice data from a payment processor like **Stripe**.
- **High-Level Purpose**: This file represents the "ground truth" for revenue. It contains the financial transactions from customers who have made a purchase. It is the final and most important piece of the puzzle for calculating Return on Ad Spend (ROAS).
- **Agent's Primary Goal**: To correctly parse this data and, most importantly, to **successfully attribute the revenue back to the original marketing campaigns**. This requires the agent to navigate a key mismatch and join data through an intermediary source.

## 2. File Structure & Schema

### Clean Data Profile

- **Location**: `data/raw_stripe_invoices.csv`
- **Schema**:
    - `invoice_id`: `TEXT`, The unique identifier for the invoice.
    - `user_uid`: `TEXT`, The user identifier, for joining to other sources.
    - `campaign_id`: `TEXT`, The campaign that generated the user.
    - `date`: `DATE`, The date of the invoice.
    - `amount_usd`: `DECIMAL`, The transaction amount in USD.
- **Generation Logic**: Records are only created for leads with a `status` of "Qualified" in the leads dataset. This results in **~1,026 rows** (since about 1/3 of the 3,000 leads are "Qualified").

### Realistic Data Profile (with Entropy)

The `add_entropy.py` script applies two critical transformations that create a major attribution challenge.

- **Key Transformations**:
    1.  **Key Mismatch (`campaign_id` Removed)**: The `campaign_id` column is **completely dropped** from the file. This is a realistic scenario, as payment systems often don't have direct knowledge of the marketing campaign that acquired a user.
    2.  **Date Format Change (Unix Timestamp)**: The `date` column is converted from a standard `YYYY-MM-DD` date into a **Unix timestamp** (e.g., `1747449600`).

- **Resulting Realistic Schema**:
    - `invoice_id`: `TEXT`
    - `user_uid`: `TEXT`
    - `date`: `INTEGER` (Unix timestamp).
    - `amount_usd`: `DECIMAL`

- **Example of Realistic Data**:

  | invoice_id | user_uid | date       | amount_usd |
  |------------|----------|------------|------------|
  | inv_abc    | user_a   | 1747449600 | 550.28     |
  | inv_def    | user_b   | 1747536000 | 275.83     |

## 3. Key Challenges & Instructions for AI Agent

1.  **Revenue Attribution (Critical Path)**: The agent CANNOT join this file directly to the ad platform data to calculate ROAS, because `campaign_id` is missing. The agent **must** perform a multi-step join.
    - **Required Join Path**: To find the `campaign_id` for a given invoice, the agent must join through the leads data:
      `raw_stripe_invoices` → `raw_hubspot_leads` (or `raw_intercom_leads`)
    - **Join Logic**: `JOIN ON raw_stripe_invoices.user_uid = raw_hubspot_leads.user_uid`
    - This will allow the agent to retrieve the `campaign_id` associated with that user from the leads table and correctly attribute the `amount_usd` from the invoice to that campaign.
2.  **Date/Time Parsing**: The agent must detect that the `date` column is a Unix timestamp.
    - It needs to convert this integer timestamp back into a standard `YYYY-MM-DD` date format to be useful for time-series analysis. Most standard libraries can handle this conversion (e.g., `pd.to_datetime(df['date'], unit='s')`).
3.  **Column Renaming**: The agent should rename columns to the internal standard for consistency.
    - `date` → `event_date`
    - `amount_usd` → `revenue_usd` (to be more specific and avoid collision with `cost_usd`).
4.  **Final Schema**: After cleaning, parsing, and joining to retrieve the campaign ID, the agent should have a data structure ready for financial analysis, with a schema like: `event_date`, `invoice_id`, `user_uid`, `campaign_id`, `revenue_usd`. 

# RAG Document: `raw_tiktok_ads.csv`

## 1. Source Description & Gist

- **File Name**: `raw_tiktok_ads.csv`
- **Data Source**: Simulates daily advertising performance from **TikTok Ads**.
- **High-Level Purpose**: This file tracks daily spend and performance for TikTok campaigns. It is a crucial source of ad spend data, but it is intentionally the "messiest" of the ad platform files to simulate the challenges of dealing with international data.
- **Agent's Primary Goal**: To ingest, clean, and standardize this complex file. The agent must handle multiple currencies, non-standard numeric formats, column name variations, and missing data to successfully unify this data with other sources.

## 2. File Structure & Schema

### Clean Data Profile

In "clean" mode, the file starts with the standard ad platform schema.

- **Location**: `data/raw_tiktok_ads.csv`
- **Initial Schema (before entropy)**:
    - `event_date`: `DATE` (`YYYY-MM-DD`)
    - `campaign_id`: `TEXT`
    - `cost_usd`: `DECIMAL`
    - `impressions`: `INTEGER`
    - `clicks`: `INTEGER`
- **Generation Logic**: The base data contains **1,800 rows** generated by the standard `build_ads()` function.

### Realistic Data Profile (with Entropy)

This file undergoes the most significant transformations in `add_entropy.py`.

- **Key Transformations**:
    1.  **Multi-Currency Introduction**: A `currency` column is added, randomly assigning `USD`, `COP` (Colombian Peso), or `MXN` (Mexican Peso) to each row.
    2.  **Local Cost Calculation**: A new `cost_local` column is created. The original `cost_usd` is multiplied by a fixed exchange rate (`COP: 4200`, `MXN: 17`) to get the cost in the local currency.
    3.  **Non-Standard Numeric Formatting**: The `cost_local` values are converted to strings with thousands separators to simulate real-world export formats.
        - **European Style**: For `COP` and `MXN`, it uses a format like `1.234.567,89`.
        - **US Style**: For `USD`, it uses a format like `1,234,567.89`.
    4.  **Column Renaming**: The columns are renamed, creating case and naming variations.
        - `cost_usd` → `Spend` (This column is then **dropped**).
        - `clicks` → `Clicks` (Capitalized).
        - `impressions` → `impressionsCount` (camelCase).
    5.  **Missing Data**: For a random **10% of rows**, the value in `impressionsCount` is replaced with an empty string `''`.

- **Resulting Realistic Schema**:
    - `date`: `TEXT` (`YYYY-MM-DD` format, but should be treated as text initially).
    - `campaign_id`: `TEXT`
    - `cost_local`: `TEXT` (string representation of cost, e.g., `'4.200.000,00'`).
    - `currency`: `TEXT` (`USD`, `COP`, `MXN`).
    - `impressionsCount`: `TEXT` (to accommodate empty strings).
    - `Clicks`: `INTEGER`.

## 3. Key Challenges & Instructions for AI Agent

1.  **Column Name Mapping**: The first step is to map the messy column names to a standard internal schema.
    - `date` → `event_date`
    - `campaign_id` → `campaign_id`
    - `cost_local` → `cost_usd` (The goal is to create a unified USD cost column).
    - `currency` → `currency`
    - `impressionsCount` → `impressions`
    - `Clicks` → `clicks`
2.  **Cost Standardization (Critical Path)**: This is the most complex task for this file.
    - **Parse `cost_local`**: The agent must first remove the thousands separators (`.` or `,`) and convert the decimal separator (`,` for European style) to a standard `.` to parse the string into a number.
    - **Currency Conversion**: After parsing, the agent must convert all `cost_local` values back to USD using the `currency` column and the inverse of the generation exchange rates.
        - `USD`: No change.
        - `COP`: Divide by `4200`.
        - `MXN`: Divide by `17`.
    - The final, standardized value should be stored in a `cost_usd` column.
3.  **Handle Missing Impressions**: The agent must scan the `impressionsCount` (`impressions`) column for empty strings and convert them to `NULL` or `0`. The column should then be cast to `INTEGER`.
4.  **Final Schema**: After all cleaning and standardization, the resulting data frame should have the standard ad platform schema (`event_date`, `campaign_id`, `cost_usd`, `impressions`, `clicks`) and be ready for unification. The `cost_local` and `currency` columns can be dropped after the `cost_usd` column is successfully created. 