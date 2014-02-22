-- Scripts needed in elis
-- NOTE: The following SQLs identify patients with problematic data. The last 7 (GANGAN*) are valid patients to remain in the system
-- but have to reset their identifier as GAN* from GANGAN*. Rest can be removed.
-- select patient_id, identity_data from patient_identity where identity_type_id = 2 and identity_data !~ '^[a-z,A-Z]{3}[0-9]{1,}' order by patient_id;

--  move samples from “GAN207330” to "GANGAN207330"
update sample_human set patient_id = 172213 where patient_id = 173064;

-- patients 173072, 174131, 173064, 141067 are essentially duplicate
-- no event records for patients “GAN207330”, “GAN207656”, “GAN208310”, "GAN२००८९४"
-- delete patient identity for “GAN207330”, “GAN207656”, “GAN208310”, "GAN२००८९४"
delete from patient_identity where patient_id in (173072, 174131, 173064, 141067);
-- delete patient for “GAN207330”, “GAN207656”, “GAN208310”, "GAN२००८९४"
delete from patient where id in (173072, 174131, 173064, 141067);
-- delete person_address for “GAN207330”, “GAN207656”, “GAN208310”, "GAN२००८९४"
delete from person_address where person_id in (141069,173092,173084,174151);
-- delete person for the patient “GAN207330”, “GAN207656”, “GAN208310”, "GAN२००८९४"
delete from person where id in (141069,173092,173084,174151);

-- truncate GAN in GANGAN ids
update patient_identity set identity_data = 'GAN207248' where identity_data = 'GANGAN207248';
update patient_identity set identity_data = 'GAN208096' where identity_data = 'GANGAN208096';
update patient_identity set identity_data = 'GAN207656' where identity_data = 'GANGAN207656';
update patient_identity set identity_data = 'GAN208310' where identity_data = 'GANGAN208310';
update patient_identity set identity_data = 'GAN206243' where identity_data = 'GANGAN206243';
update patient_identity set identity_data = 'GAN207330' where identity_data = 'GANGAN207330';
update patient_identity set identity_data = 'GAN207175' where identity_data = 'GANGAN207175';

-- delete identifiers for patients like GA1, G1, S10, GA0 etc.
delete from patient_identity where patient_id in (51955,52824,53393,53413,53745,53873,54672,55060,55096,55100,55463,55464,56552,57105,57742,58208,58412,58515,61906,61910,61911,61966,61970,61974,61986,65255,67819,71286,71344,75671,75860,76997,77020,77408,77709,77879,78049,78108,78826,78832,79081,80301,80566,81130,87385,87484);
-- delete patient for patients like GA1, G1, SI0, GA0 etc.
delete from patient where id in (51955,52824,53393,53413,53745,53873,54672,55060,55096,55100,55463,55464,56552,57105,57742,58208,58412,58515,61906,61910,61911,61966,61970,61974,61986,65255,67819,71286,71344,75671,75860,76997,77020,77408,77709,77879,78049,78108,78826,78832,79081,80301,80566,81130,87385,87484);
-- delete person_address for patients like GA1, G1, SI0, GA0 etc.
delete from person_address where person_id in (61912, 67821, 75862, 77410, 61976, 51957, 61988, 75673, 53875, 61972, 71346, 58517, 55466, 61908, 55098, 57107, 55465, 58210, 57744, 77022, 78051, 52826, 80303, 80568, 61913, 71288, 79083, 56554, 58414, 53415, 78828, 54674, 77881, 87387, 78834, 55062, 55102, 53747, 53395, 77711, 87486, 81132, 61968, 78110, 76999, 65257);
-- delete person for patients like GA1, G1, SI0, GA0 etc.
delete from person where id in (61912, 67821, 75862, 77410, 61976, 51957, 61988, 75673, 53875, 61972, 71346, 58517, 55466, 61908, 55098, 57107, 55465, 58210, 57744, 77022, 78051, 52826, 80303, 80568, 61913, 71288, 79083, 56554, 58414, 53415, 78828, 54674, 77881, 87387, 78834, 55062, 55102, 53747, 53395, 77711, 87486, 81132, 61968, 78110, 76999, 65257);



update sample_human set patient_id=173176 where patient_id=174734;
delete from patient_identity where patient_id in (174454, 174734);
delete from patient where id in (174454, 174734);
delete from person_address where person_id in (174474, 174754);
delete from person where id in (174474, 174754);
