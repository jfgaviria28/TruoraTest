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