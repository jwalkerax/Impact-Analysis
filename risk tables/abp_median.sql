SELECT median
FROM
(
  SELECT npi, abp_score, PERCENTILE_CONT(0.5) OVER (ORDER BY abp_score) AS median
  FROM temp_client1.abp_all_npis --bcbst_dev.abp_all_npis
  WHERE abp_score IS NOT NULL
)
LIMIT 1
