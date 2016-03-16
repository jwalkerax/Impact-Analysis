SELECT
  a.axial_member_id AS axial_member_id,
  a.service_from_yyyy_mm,
  ROUND(SUM(a.amount_allowed),2) AS total_allowed_medical_spend,
  ROUND(SUM(CASE WHEN d.pain_group = 'pain' THEN a.amount_allowed ELSE 0 END), 2) AS total_pain_spend,
  ROUND(SUM(CASE WHEN d.pain_group <> 'pain' OR d.pain_group IS NULL THEN a.amount_allowed ELSE 0 END), 2) AS total_nonpain_spend,
  ROUND(SUM(r.amount_allowed),2) AS total_allowed_rx_spend,
  ROUND(SUM(CASE WHEN LOWER(r.pharm_classes) LIKE '%opioid%' THEN r.amount_allowed ELSE 0 END),2) AS total_opioid_rx_spend,
  ROUND(SUM(CASE WHEN LOWER(r.pharm_classes) NOT LIKE '%opioid%' OR r.pharm_classes IS NULL
                  THEN r.amount_allowed ELSE 0 END),2) AS total_nonopioid_rx_spend
FROM
  bcbst_prod.vw_medical_claims a JOIN
  ref_dev.diagnosis_master d ON a.icd_type = d.icdtype AND a.icd_code_1 = d.unformatted_icd_dx_code FULL OUTER JOIN EACH
  bcbst_prod.vw_rx_claims r ON a.axial_member_id = r.axial_member_id AND a.service_from_yyyy_mm = r.service_from_yyyy_mm
WHERE a.axial_member_id IS NOT NULL
--AND a.service_from_yyyy_mm IN('2015-11', '2015-12')
GROUP BY
  axial_member_id,
  a.service_from_yyyy_mm
ORDER BY
  axial_member_id, a.service_from_yyyy_mm
