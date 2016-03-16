SELECT
  a.axial_member_id AS axial_member_id,
  a.service_from_yyyy_mm,
  EXACT_COUNT_DISTINCT(STRING(a.axial_member_id) + a.service_from_date + a.servicing_provider_npi + a.icd_code_1) AS total_visits,
  EXACT_COUNT_DISTINCT(CASE WHEN d.pain_group = 'pain'
                            THEN STRING(a.axial_member_id) + a.service_from_date + a.servicing_provider_npi + a.icd_code_1
                            ELSE NULL END) AS pain_visits,
  EXACT_COUNT_DISTINCT(CASE WHEN d.pain_group <> 'pain'
                            OR d.pain_group IS NULL
                            THEN STRING(a.axial_member_id) + a.service_from_date + a.servicing_provider_npi + a.icd_code_1
                            ELSE NULL END) AS nonpain_visits,

  EXACT_COUNT_DISTINCT(STRING(r.axial_member_id) + r.service_from_date + r.ndc) AS total_prescriptions,
  EXACT_COUNT_DISTINCT(CASE WHEN LOWER(r.pharm_classes) LIKE '%opioid%'
                            THEN STRING(r.axial_member_id) + r.service_from_date + r.ndc
                            ELSE NULL END) AS pain_prescriptions,
  EXACT_COUNT_DISTINCT(CASE WHEN LOWER(r.pharm_classes) NOT LIKE '%opioid%'
                            OR r.pharm_classes IS NULL
                            THEN STRING(r.axial_member_id) + r.service_from_date + r.ndc
                            ELSE NULL END) AS nonpain_prescriptions
FROM
  bcbst_prod.vw_medical_claims a JOIN
  ref_dev.vw_diagnosis_master d ON a.icd_type = d.icdtype AND a.icd_code_1 = d.unformatted_icd_dx_code FULL OUTER JOIN EACH
  bcbst_prod.vw_rx_claims r ON a.axial_member_id = r.axial_member_id AND a.service_from_yyyy_mm = r.service_from_yyyy_mm
WHERE a.axial_member_id IS NOT NULL
--AND a.service_from_yyyy_mm = '2014-01'
GROUP BY
  axial_member_id,
  a.service_from_yyyy_mm
ORDER BY
  axial_member_id, a.service_from_yyyy_mm
