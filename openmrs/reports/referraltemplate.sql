SELECT
  pi.identifier as 'Identifier',
  t.given_name   AS 'Given Name',
  t.family_name as 'Family Name',
  Gender,
  Age,
  MAX(CASE WHEN t.concept_full_name = 'Doctor\'s Name'
    THEN t.value
      ELSE NULL END) AS 'Doctor\'s Name',
  MAX(CASE WHEN t.concept_full_name = 'Referral Form, Authority'
    THEN t.value
      ELSE NULL END) AS 'Authority',

  MAX(CASE WHEN t.concept_full_name = 'Referral Form, Facility Type '
    THEN t.value
      ELSE NULL END) AS 'Facility Type',
  MAX(CASE WHEN t.concept_full_name = 'Referral Form, District'
    THEN t.name
      ELSE NULL END) AS 'District',
  MAX(CASE WHEN t.concept_full_name = 'Referral Form, State'
    THEN t.name
      ELSE NULL END) AS 'State',

  MAX(CASE WHEN t.concept_full_name = 'Summary, Advice'
    THEN (t.name)
      ELSE NULL END) AS 'Advice',
  MAX(CASE WHEN t.concept_full_name = 'Summary, Summary Notes '
      THEN t.value
        ELSE NULL END) AS 'Summary',
  MAX(CASE WHEN t.concept_full_name = 'Contact '
    THEN t.value
      ELSE NULL END) AS 'Contact',
  MAX(CASE WHEN t.concept_full_name = 'Follow up after (months)'
    THEN t.value
      ELSE NULL END) AS 'Follow up after',
  MAX(CASE WHEN t.concept_full_name = 'Follow up on (date)'
    THEN t.value
      ELSE NULL END) AS 'Follow up Date',
  group_concat(DISTINCT t.Diagnosis SEPARATOR '; ') as Diagnosis
FROM obs o
  INNER JOIN patient_identifier pi ON pi.patient_id = o.person_id
  INNER JOIN
  (SELECT DISTINCT
     pi.identifier,
     pn.given_name                                    AS given_name,
     pn.family_name                                   AS family_name,
     p.gender                                         as Gender,
     floor(DATEDIFF(DATE(o.date_created), p.birthdate) / 365)   AS Age,
     vt.name                                          AS visit_type,
     vt.date_created                                   as visit_start,
     cv.concept_full_name,
     ifnull(o.value_text, ifnull(cv2.concept_short_name, ifnull(o.value_datetime,o.value_numeric))) AS value,
     o.obs_group_id,
     o.concept_id,
     cv2.concept_full_name                            AS name,
    diag.name as Diagnosis,

     o.obs_datetime
   FROM obs o
     INNER JOIN concept_view cv ON cv.concept_id = o.concept_id and o.concept_id IN (SELECT cs.concept_id from concept_set cs where cs.concept_set in  (select cs.concept_id
                                                                                                                                                        FROM concept_set cs INNER JOIN
                                                                                                                                                          concept_view cv ON cv.concept_id = cs.concept_set AND cv.concept_full_name = 'Referral Form'))
                                   AND o.voided = 0 AND
                                   cast(o.obs_datetime AS DATE) BETWEEN '#startDate#' and '#endDate#'
     LEFT JOIN concept_view cv2 ON cv2.concept_id = o.value_coded



     INNER JOIN person p ON p.person_id = o.person_id


     INNER JOIN encounter e ON e.encounter_id = o.encounter_id

     INNER JOIN visit v ON v.visit_id = e.visit_id
     INNER JOIN visit_type vt ON vt.visit_type_id = v.visit_type_id
     INNER JOIN person_name pn ON pn.person_id = o.person_id
     INNER JOIN patient_identifier pi ON pi.patient_id = o.person_id
    left join  confirmed_diagnosis_view_new diag on diag.person_id=o.person_id
  ) AS t ON t.identifier = pi.identifier

GROUP BY t.given_name, t.family_name;