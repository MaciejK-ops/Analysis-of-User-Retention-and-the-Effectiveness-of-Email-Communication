WITH
  -- 1. Fetch and aggregate account creation data grouped by date, country, and status flags
  accounts_data AS (
    SELECT
      s.date AS date,
      sp.country,
      ac.send_interval,
      ac.is_verified,
      ac.is_unsubscribed,
      COUNT(ac.id) AS account_cnt,  -- Number of registered accounts
      0 AS sent_msg,                -- Zero-fill to align column structure for UNION ALL
      0 AS open_msg,
      0 AS visit_msg
    FROM `data-analytics-mate.DA.account` AS ac
    JOIN `data-analytics-mate.DA.account_session` AS acs
      ON acs.account_id = ac.id
    JOIN `data-analytics-mate.DA.session` AS s
      ON s.ga_session_id = acs.ga_session_id
    JOIN `data-analytics-mate.DA.session_params` AS sp
      ON sp.ga_session_id = s.ga_session_id
    GROUP BY 1, 2, 3, 4, 5
  ),

  -- 2. Fetch and aggregate email metrics (sent, opened, visited/clicked)
  emails_data AS (
    SELECT
      -- Calculate the actual email send date (session date + day offset)
      DATE_ADD(CAST(s.date AS DATE), INTERVAL CAST(es.sent_date AS INT64) DAY) AS date,
      sp.country,
      ac.send_interval,
      ac.is_verified,
      ac.is_unsubscribed,
      0 AS account_cnt,                             -- Zero-fill (no new account registrations in this set)
      COUNT(DISTINCT es.id_account) AS sent_msg,    -- Unique accounts that received an email
      COUNT(DISTINCT eo.id_account) AS open_msg,    -- Unique accounts that opened an email
      COUNT(DISTINCT ev.id_account) AS visit_msg   -- Unique accounts that clicked an email link
    FROM `data-analytics-mate.DA.account` AS ac
    JOIN `data-analytics-mate.DA.account_session` AS acs
      ON acs.account_id = ac.id
    JOIN `data-analytics-mate.DA.session` AS s
      ON s.ga_session_id = acs.ga_session_id
    JOIN `data-analytics-mate.DA.session_params` AS sp
      ON sp.ga_session_id = s.ga_session_id
    JOIN `data-analytics-mate.DA.email_sent` AS es
      ON es.id_account = acs.account_id
    LEFT JOIN `data-analytics-mate.DA.email_open` AS eo
      ON eo.id_account = es.id_account
    LEFT JOIN `data-analytics-mate.DA.email_visit` AS ev
      ON ev.id_account = es.id_account
    GROUP BY 1, 2, 3, 4, 5
  ),

  -- 3. Combine account and email datasets into a single stream
  combined_data AS (
    SELECT * FROM accounts_data
    UNION ALL
    SELECT * FROM emails_data
  ),

  -- 4. Consolidate combined records by summing metrics across matching dimensions
  aggregated_data AS (
    SELECT
      date,
      country,
      send_interval,
      is_verified,
      is_unsubscribed,
      SUM(account_cnt) AS account_cnt,
      SUM(sent_msg) AS sent_msg,
      SUM(open_msg) AS open_msg,
      SUM(visit_msg) AS visit_msg
    FROM combined_data
    GROUP BY 1, 2, 3, 4, 5
  ),

  -- 5. Calculate overall country totals using window functions
  windowed_stats AS (
    SELECT
      *,
      SUM(account_cnt) OVER (PARTITION BY country) AS total_country_account_cnt, -- Total accounts registered per country
      SUM(sent_msg) OVER (PARTITION BY country) AS total_country_sent_cnt        -- Total emails sent per country
    FROM aggregated_data
  ),

  -- 6. Rank countries based on total accounts and total emails sent
  ranked_stats AS (
    SELECT
      *,
      DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt, -- Country rank by account volume
      DENSE_RANK() OVER (ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt     -- Country rank by email volume
    FROM windowed_stats
  )

-- 7. Output final dataset filtered to top 10 countries in either category
SELECT
  date,
  country,
  send_interval,
  is_verified,
  is_unsubscribed,
  account_cnt,
  sent_msg,
  open_msg,
  visit_msg,
  total_country_account_cnt,
  total_country_sent_cnt,
  rank_total_country_account_cnt,
  rank_total_country_sent_cnt
FROM ranked_stats
WHERE rank_total_country_account_cnt <= 10  -- Within Top 10 by total accounts
   OR rank_total_country_sent_cnt <= 10     -- OR within Top 10 by total emails sent
ORDER BY country;
