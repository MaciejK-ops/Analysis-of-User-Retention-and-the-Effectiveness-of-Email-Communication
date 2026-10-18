# User Retention & Email Communication Effectiveness

A data analytics portfolio project exploring user account creation dynamics, email engagement metrics, and retention patterns. The project provides actionable insights into user behavior across geographic markets, account verification states, and subscription preferences.


## Business questions

- What is the daily trend of account creation and email dispatch volume?
- Which geographic markets (countries) generate the largest volume of accounts and engagement?
- How do email sending intervals affect open rates (OR) and click-through rates (CTR)?
- What is the relationship between account verification status and long-term user retention?
- How do user behaviors differ across active vs. inactive subscription statuses?

## Report contents

The Looker Studio dashboard and SQL analyses focus on cohort retention, engagement metrics, and user segmentation. Filters allow granular inspection across time frames, geographic regions, and account statuses.

Key metrics and dimensions analyzed include:

- **Volume Metrics:** Total accounts created, total emails sent, opened, and clicked.
- **Engagement Rates:** Open Rate (OR) and Click-Through Rate (CTR) by country and user segment.
- **Time Dynamics:** Time-gap analysis between consecutive emails and initial account verification times.
- **Segmentation Breakdown:** User cohorts by verification status and subscription preferences.

**Metric interpretation:** High email sending volume does not automatically translate to higher retention. Time-interval optimization and account verification are key drivers for sustained engagement.

## Tools

- **SQL** — data extraction, window functions for interval calculation, and cohort aggregation
- **Looker Studio** — interactive dashboard authoring and data visualization
- **Git & GitHub** — project version control and documentation

## Repository files

- `sql/Analysis-of-User-Retention-and-the-Effectiveness-of-Email-Communication.sql` — SQL queries for data extraction and metric calculations
- `reports/Email Communication & Account Overview.pdf` — complete dashboard visual export

## How to explore the report

1. Review the SQL logic in the `sql/` directory to understand the underlying data transformations and metric definitions.
2. Open `reports/Email Communication & Account Overview.pdf` to view the layout and visual structure of the report.
3. Check the summary findings below for key business takeaways derived from the data.

## Data notes and limitations

- The dataset covers a specific historical window (e.g., late 2020 to early 2021).
- Time-gap calculations rely on timestamp logging accuracy for email dispatches and user interactions.
- Geographic attribution is based on user profile settings at account creation.


- Implement predictive churn modeling based on early email interaction intervals.
- Add A/B testing frameworks for optimal email dispatch timing.
- Build automated data pipelines to refresh the Looker Studio dashboard dynamically.

## Author

Created as a data analytics portfolio project by [MaciejK-ops](https://github.com/MaciejK-ops).
