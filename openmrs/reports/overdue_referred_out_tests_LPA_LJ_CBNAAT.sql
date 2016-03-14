select  PID.identity_data as "Patient Id", PNAME.identity_data as Name,
  test.name Test, type_of_sample.description Sample,
  organization.name Centre, referral.requester_name Requester, date(referral.referral_request_date) as "Request Date", (current_date - date(referral_request_date)) as Days
from clinlims.referral
LEFT JOIN clinlims.organization ON referral.organization_id = organization.id
LEFT JOIN clinlims.analysis ON referral.analysis_id = analysis.id
LEFT JOIN clinlims.test ON (analysis.test_id = test.id AND test.name IN ('LPA','LJ', 'CBNAAT'))
LEFT JOIN clinlims.sample_item ON analysis.sampitem_id = sample_item.id
LEFT JOIN clinlims.type_of_sample ON type_of_sample.id = sample_item.typeosamp_id
LEFT JOIN clinlims.sample_human ON sample_item.samp_id = sample_human.samp_id
LEFT JOIN clinlims.patient_identity PID ON (sample_human.patient_id = PID.patient_id AND PID.identity_type_id = 2)
LEFT JOIN clinlims.patient_identity PNAME ON (PNAME.patient_id = PID.patient_id AND PNAME.identity_type_id = 36)
      WHERE (
        (current_date - date(referral_request_date) > 7 AND test.name = 'CBNAAT' AND referral.sent_date is NULL)
        OR (current_date - date(referral_request_date) > 14 AND test.name = 'LPA' AND referral.sent_date is NULL)
        OR (current_date - date(referral_request_date) > 84 AND test.name = 'LJ' AND referral.sent_date is NULL)
      )
;
