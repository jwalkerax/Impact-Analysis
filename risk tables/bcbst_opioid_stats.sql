SELECT
  pat.month,
  pat.year,
  pat.opioid_patients,
  prescript.opioid_prescriptions,
  poly.polydrug_cases,
  multi_pres.patients_with_multi_prescriber
FROM
  ( --Number of patients on opioids per month
    SELECT MONTH(mon_start) AS month, YEAR(mon_start) AS year, EXACT_COUNT_DISTINCT(axial_member_id) AS opioid_patients
    FROM bcbst_prod.monthly_medd
    GROUP BY month, year
    ORDER BY year, month
  ) AS pat
  JOIN
  ( -- Number of opioid prescripts per month
    SELECT  service_from_year,service_from_month, EXACT_COUNT_DISTINCT(claim_id) AS opioid_prescriptions
    FROM [bcbst_prod.vw_rx_claims]
    WHERE LOWER(pharm_classes) like '%opioid%'
    GROUP BY service_from_year, service_from_month
    ORDER BY service_from_year, service_from_month
  ) AS prescript
  ON
    pat.month = prescript.service_from_month AND
    pat.year = prescript.service_from_year

  JOIN
  ( --Number of poly-drug cases per month
    SELECT registry_year, registry_month, EXACT_COUNT_DISTINCT(axial_member_id) AS polydrug_cases
    FROM bcbst_dev.rim_patient_polydrug
    GROUP BY registry_year, registry_month
    ORDER BY registry_year, registry_month
  ) AS poly
  ON
    pat.month = poly.registry_month AND
    pat.year = poly.registry_year

  JOIN
  ( --Number of multiple opioid prescriptions per month
    SELECT registry_year, registry_month, EXACT_COUNT_DISTINCT(axial_member_id) AS patients_with_multi_prescriber
    FROM [bcbst_dev.rim_patient_multi_prescriber]
    GROUP BY registry_year, registry_month
    ORDER BY registry_year, registry_month
  ) AS multi_pres
  ON
    pat.month = multi_pres.registry_month AND
    pat.year = multi_pres.registry_year

ORDER BY
  pat.year, pat.month
