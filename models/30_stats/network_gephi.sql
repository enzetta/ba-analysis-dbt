WITH
  SOURCE AS (
  SELECT
    SOURCE,
    TARGET,
    FORMAT_DATE('%Y-%m-%d', month_start) AS month_start,
    SUM(weight) AS weight
  FROM
    {{ ref('network_all_users') }}
  WHERE
    month_start = TIMESTAMP("2020-09-01")
    -- month_start = TIMESTAMP("2021-03-01")
    -- month_start = TIMESTAMP("2021-09-01")
  GROUP BY SOURCE,
    TARGET,
    month_start
  ORDER BY
    month_start,
    weight DESC )
SELECT
  *
FROM
  SOURCE
WHERE
  weight > 2