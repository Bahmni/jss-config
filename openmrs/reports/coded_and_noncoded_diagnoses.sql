select * from (
      SELECT
            patient_identifier.identifier AS Patient,
            value_text AS 'Diagnosis',
            date(diagnosis.obs_datetime) AS Date,
            username AS Provider
      FROM obs diagnosis, users, patient_identifier
      WHERE diagnosis.concept_id = 42
            AND diagnosis.creator = users.user_id
            AND patient_identifier.patient_id = diagnosis.person_id
      UNION

      SELECT
            patient_identifier.identifier AS Patient,
            coded_diagnosis.name AS 'Diagnosis',
            date(diagnosis.obs_datetime) AS Date,
            username AS Provider
      FROM obs diagnosis, users, patient_identifier, concept_name coded_diagnosis
      WHERE diagnosis.concept_id = 43
            AND diagnosis.creator = users.user_id
            AND patient_identifier.patient_id = diagnosis.person_id
            AND diagnosis.value_coded = coded_diagnosis.concept_id
            AND concept_name_type='FULLY_SPECIFIED'
) all_diagnoses
;