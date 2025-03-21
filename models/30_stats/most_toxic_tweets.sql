WITH RankedTweets AS (
  SELECT 
    users.screen_name,
    tweets.tweet_id,
    tweets.created_at,
    tweets.text,
    tweets.toxicity_score,
    tweets.sentiment_score,
    tweets.party,
    RANK() OVER (PARTITION BY users.screen_name ORDER BY toxicity_score DESC) AS toxic_rank,
    RANK() OVER (PARTITION BY users.screen_name ORDER BY toxicity_score ASC) AS non_toxic_rank,
    RANK() OVER (PARTITION BY users.screen_name ORDER BY ABS(sentiment_score) ASC) AS neutral_rank
  FROM 
    `grounded-nebula-408412.twitter_analysis_20_curated.tweets_relevant_with_predictions` AS tweets
  LEFT JOIN 
    `grounded-nebula-408412.twitter_analysis_00_source.users` AS users
  ON 
    tweets.user_id = users.user_id
  WHERE 
    users.screen_name IN ("screen_name1", "screen_name2", "screen_name3")  -- 🔹 Replace with your list of accounts
)
SELECT 
  screen_name,
  tweet_id,
  created_at,
  text,
  toxicity_score,
  sentiment_score,
  party,
  CASE 
    WHEN toxic_rank <= 10 THEN 'Most Toxic'
    WHEN non_toxic_rank <= 10 THEN 'Least Toxic'
    WHEN neutral_rank <= 10 THEN 'Most Neutral'
  END AS category
FROM RankedTweets
WHERE toxic_rank <= 10 OR non_toxic_rank <= 10 OR neutral_rank <= 10
ORDER BY screen_name, category, toxicity_score DESC;