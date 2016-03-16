SELECT
  service_from_yyyy_mm,
  b.members,
  ROUND(SUM(total_allowed_medical_spend),2) as total_med,
  ROUND(SUM(total_pain_spend),2) as total_direct_pain,
  ROUND(SUM(total_nonpain_spend),2) as total_nonpain,
  ROUND(SUM(total_allowed_rx_spend),2) as total_rx,
  ROUND(SUM(total_opioid_rx_spend),2) as total_opioid,
  ROUND(SUM(total_nonopioid_rx_spend),2) as total_nonopioid
FROM
  [zz_JAW.member_spend_per_month] a JOIN
  (
    SELECT member_yyyy_mm, EXACT_COUNT_DISTINCT(axial_member_id) AS members
    FROM bcbst_prod.member_month_by_lob
    --WHERE lob = 'MEDICIAD'
    GROUP BY member_yyyy_mm
  ) b ON a.service_from_yyyy_mm = b.member_yyyy_mm
GROUP BY service_from_yyyy_mm, b.members
ORDER BY service_from_yyyy_mm, b.members 
