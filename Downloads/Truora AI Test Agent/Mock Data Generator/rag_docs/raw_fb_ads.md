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