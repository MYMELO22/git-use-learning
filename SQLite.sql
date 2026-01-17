WITH user_activity AS (
  SELECT *, 
    userid, free_trial_start_date, 
    SUM(n_sessions) AS total_sessions,
    AVG(n_sessions) AS avg_daily_sessions, count(DISTINCT day) as days,
PERCENT_RANK() OVER (ORDER BY count(DISTINCT day)) AS activity_percentile
  FROM 
    CaseStudyData
  WHERE 
    n_sessions IS NOT NULL  -- Exclude null session counts
  GROUP BY 
    userid
)

  SELECT
    userid,free_trial_start_date,days,
    total_sessions, avg_daily_sessions,activity_percentile,
    CASE 
      WHEN activity_percentile >= 0.9 THEN 'Top 10%'
      ELSE 'Bottom 90%'
    END AS user_group --activeby_total_ss
  --CASE 
      --WHEN active_percentile >= 0.9 THEN 'Top 10%'
     -- ELSE 'Bottom 90%'
   -- END AS user_group -- activeby_days
  FROM 
    user_activity



-- Count channels by user group
channel_counts AS (
  SELECT
    ug.user_group,
    csd.channel,
    COUNT(distinct ug.userid) AS channel_count
  FROM 
    CaseStudyData csd
  JOIN 
    user_groups ug ON csd.userid || free_trial_start_date = ug.user
  WHERE
    csd.channel IS NOT NULL
  GROUP BY 1,2
),

ranked_channels AS (
  SELECT
    user_group,
    channel,
    channel_count,
    RANK() OVER (PARTITION BY user_group ORDER BY channel_count DESC) AS channel_rank
  FROM
    channel_counts
)

SELECT
  ug.user_group, 
  COUNT(DISTINCT ug.userid) AS trials,
  COUNT(DISTINCT csd.userid) AS users,
  -- Feature engagement metrics (simplified for example)
  ROUND(AVG(ug.total_sessions), 1) AS avg_sessions_per_user,
  ROUND(AVG(ug.avg_daily_sessions), 1) AS avg_daily_sessions_per_user,
  
  -- Feature engagement metrics
  ROUND(AVG(COALESCE(n_feature1_views, 0)), 1) AS avg_feature1_views,
  ROUND(AVG(COALESCE(n_feature2_views, 0)), 1) AS avg_feature2_views,
  ROUND(AVG(COALESCE(n_feature3_views, 0)), 1) AS avg_feature3_views,
  ROUND(AVG(COALESCE(n_feature4_views, 0)), 1) AS avg_feature4_views,
  ROUND(AVG(COALESCE(n_feature5_views, 0)), 1) AS avg_feature5_views
  
  -- Percentage who used each feature

FROM 
  CaseStudyData csd
JOIN 
  user_groups ug ON csd.userid = ug.userid and csd.free_trial_start_date = ug.free_trial_start_date

where n_sessions is not NULL
GROUP BY 
  ug.user_group



