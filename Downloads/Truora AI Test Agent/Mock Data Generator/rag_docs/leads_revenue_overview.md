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