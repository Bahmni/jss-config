select  PID.identity_data as "Patient Id", concat(person.first_name,' ', person.last_name) as "Name",
        test.name Test, type_of_sample.description Sample,
        organization.name Centre, referral.requester_name Requester, date(referral.referral_request_date) as "Request Date", (current_date - date(referral_request_date)) as Days
from clinlims.referral
  INNER JOIN clinlims.organization ON referral.organization_id = organization.id
  INNER JOIN clinlims.analysis ON referral.analysis_id = analysis.id
  INNER JOIN clinlims.test ON (analysis.test_id = test.id AND (test.name like 'LPA%' OR test.name like 'LJ%' OR test.name like 'CBNAAT%'))
  INNER JOIN clinlims.sample_item ON analysis.sampitem_id = sample_item.id
  INNER JOIN clinlims.type_of_sample ON type_of_sample.id = sample_item.typeosamp_id
  INNER JOIN clinlims.sample_human ON sample_item.samp_id = sample_human.samp_id
  INNER JOIN clinlims.patient_identity PID ON (sample_human.patient_id = PID.patient_id AND PID.identity_type_id = 2)
  INNER JOIN clinlims.patient ON (patient.id = sample_human.patient_id)
  INNER JOIN clinlims.person ON (person.id = patient.person_id)
WHERE (
  (current_date - date(referral_request_date) > 7 AND test.name like 'CBNAAT%' AND referral.sent_date is NULL)
  OR (current_date - date(referral_request_date) > 14 AND test.name like 'LPA%' AND referral.sent_date is NULL)
  OR (current_date - date(referral_request_date) > 84 AND test.name like 'LJ%' AND referral.sent_date is NULL)
)
;
