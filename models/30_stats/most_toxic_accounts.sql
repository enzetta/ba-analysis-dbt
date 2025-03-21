WITH AggregatedToxicity AS (
  SELECT 
    node_id,
    party,
    SUM(toxicity_sent) / NULLIF(SUM(interactions_sent), 0) AS avg_toxicity_sent,
    SUM(toxicity_received) / NULLIF(SUM(interactions_received), 0) AS avg_toxicity_received,
    SUM(interactions_sent) AS total_interactions_sent,
    SUM(interactions_received) AS total_interactions_received,
    COUNT(DISTINCT month_start) AS months_active
  FROM `grounded-nebula-408412.twitter_analysis_30_network_analysis.nodes_all`
  WHERE party IS NOT NULL
  GROUP BY node_id, party
), RankedNodes AS (
  SELECT 
    node_id,
    party,
    avg_toxicity_sent,
    avg_toxicity_received,
    total_interactions_sent,
    total_interactions_received,
    months_active,
    -- Avoid LOG10(0) error by replacing 0 with 1
    RANK() OVER (
      PARTITION BY party 
      ORDER BY avg_toxicity_sent * LOG10(COALESCE(NULLIF(total_interactions_sent, 0), 1)) DESC
    ) AS rank_sent,
    RANK() OVER (
      PARTITION BY party 
      ORDER BY avg_toxicity_received * LOG10(COALESCE(NULLIF(total_interactions_received, 0), 1)) DESC
    ) AS rank_received
  FROM AggregatedToxicity
)
SELECT 
  node_id,
  party,
  avg_toxicity_sent,
  avg_toxicity_received,
  total_interactions_sent,
  total_interactions_received,
  months_active,
  rank_sent,
  rank_received
FROM RankedNodes
WHERE rank_sent <= 10 OR rank_received <= 10
ORDER BY party, rank_sent, rank_received;