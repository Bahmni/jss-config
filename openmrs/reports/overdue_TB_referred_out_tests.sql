select  PID.identity_data as "Patient Id", PNAME.identity_data as Name, test.name Test, organization.name Centre,
       referral.requester_name Requester,
       date(referral.referral_request_date) as "Request Date", (current_date - date(referral_request_date)) as Days
from clinlims.referral, clinlims.organization, clinlims.analysis, clinlims.test, clinlims.sample_item, clinlims.sample_human,
  clinlims.patient_identity PID, clinlims.patient_identity PNAME, clinlims.result
where referral.organization_id = organization.id
      and referral.analysis_id = analysis.id
      and analysis.test_id = test.id
      and analysis.sampitem_id = sample_item.id
      and sample_item.samp_id = sample_human.samp_id
      and sample_human.patient_id = PID.patient_id
      And PID.identity_type_id = 2
      AND PNAME.patient_id = PID.patient_id
      AND PNAME.identity_type_id = 36
      AND result.analysis_id = analysis.id
      AND (
        (current_date - date(referral_request_date) > 7 AND test.name LIKE '%CBNAAT%' AND referral.sent_date is NULL)
        OR (current_date - date(referral_request_date) > 14 AND test.name LIKE '%LPA%' AND referral.sent_date is NULL)
        OR (current_date - date(referral_request_date) > 84 AND test.name LIKE '%LJ%' AND referral.sent_date is NULL)
      )
;
