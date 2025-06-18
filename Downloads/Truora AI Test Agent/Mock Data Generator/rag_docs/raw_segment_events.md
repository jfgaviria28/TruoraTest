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