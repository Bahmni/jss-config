select identifier, Diagnosis, diagnosis_date, username,
      CASE coded_noncoded
        WHEN 42 THEN 'Non-Coded'
        ELSE 'Coded'
      END as 'Coded/Non-Coded'
from (
      SELECT
            patient_identifier.identifier,
            value_text AS 'Diagnosis',
            date(diagnosis.obs_datetime) diagnosis_date,
            username,
            diagnosis.concept_id coded_noncoded
      FROM obs diagnosis, users, patient_identifier
      WHERE diagnosis.concept_id = 42
            AND date(diagnosis.obs_datetime) between '#startDate#' and '#endDate#'
            AND diagnosis.creator = users.user_id
            AND patient_identifier.patient_id = diagnosis.person_id
      UNION ALL

      SELECT
            patient_identifier.identifier,
            coded_diagnosis.name AS 'Diagnosis',
            date(diagnosis.obs_datetime) diagnosis_date,
            username,
            diagnosis.concept_id coded_noncoded
      FROM obs diagnosis, users, patient_identifier, concept_name coded_diagnosis
      WHERE diagnosis.concept_id = 43
            AND date(diagnosis.obs_datetime) between '#startDate#' and '#endDate#'
            AND diagnosis.creator = users.user_id
            AND patient_identifier.patient_id = diagnosis.person_id
            AND diagnosis.value_coded = coded_diagnosis.concept_id
            AND concept_name_type='FULLY_SPECIFIED'

) all_diagnoses
ORDER BY diagnosis_date
;
