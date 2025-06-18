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