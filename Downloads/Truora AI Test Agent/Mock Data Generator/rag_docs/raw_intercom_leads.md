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