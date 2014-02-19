-- Find duplicate uuid in patient 
-- select uuid, count(*) from patient group by uuid having count(*) > 1;

-- Duplicate Patient ids with no sample. OK to delete.
-- 153165
-- 170209

-- Duplicate patient ids where both have sample.
-- 170750 (keeping this intact) GAN206318
-- 170830 (deleting this. transferring sample to patient 170750)

delete from patient_identity where patient_id in (153165, 170209, 170830);
delete from patient where id in (153165, 170209);

update sample_human set patient_id = 170750 where patient_id = 170830;
delete from patient where id = 170830;

delete from person_address where person_id in (153182, 170229, 170850);
delete from person where id in (153182, 170229, 170850);
