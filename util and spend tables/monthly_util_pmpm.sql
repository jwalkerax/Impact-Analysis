SELECT
  service_from_yyyy_mm,
  b.members,
  SUM(total_visits) as total_visits,
  SUM(pain_visits) as total_pain_visits,
  SUM(nonpain_visits) as total_nonpain_visits,
  SUM(total_prescriptions) as total_prescriptions,
  SUM(pain_prescriptions) as total_opioid_prescriptions,
  SUM(nonpain_prescriptions) as total_nonopioid_prescriptions
FROM
  [zz_JAW.vw_member_visits_per_month] a JOIN
  (
    SELECT member_yyyy_mm, EXACT_COUNT_DISTINCT(axial_member_id) AS members
    FROM bcbst_prod.member_month_by_lob
    --WHERE lob = 'MEDICIAD'
    GROUP BY member_yyyy_mm
  ) b ON a.service_from_yyyy_mm = b.member_yyyy_mm
GROUP BY service_from_yyyy_mm, b.members
ORDER BY service_from_yyyy_mm, b.members
