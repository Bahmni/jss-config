-- delete blank encounter for patient 'GAN२००८९४'
delete from encounter where patient_id = 145335;
-- delete blank visit for patient 'GAN२००८९४'
delete from visit where patient_id = 145335;

-- delete all invalid patient information, for whom there are no visits, encounters
delete from patient_identifier where identifier in ("GA1012866", "GA1012013", "GA1022499", "GA0102483", "GA1022500", "GA1025211", "GA0103516", "GA0103949", "GA0103992", "GA0103994", "GA1043182", "G10434325", "GA0104419", "GA0105686", "GA0106101", "GA0106666", "GA1068119", "G10434326", "GA110004", "GA110002", "GA110003", "GA1010005", "GA110006", "GA110007", "GA1010002", "GA0112898", "GA1152334", "GA1184727", "GA1118502", "GA1222617", "SI0121690", "G10434327", "GA1123849", "GA124221.", "GA1245913", "GA1245579", "GA1249459", "GA1235012", "GA1256325", "GA0125610", "GA1259101", "GA1265929", "GA1271190", "GA1277260", "GA1333768", "GA1333849", "GAN२००८९४");
delete from patient where patient_id in (56873, 59966, 78712, 54797, 56071, 56455, 56500, 56499, 57975, 58531, 59177, 59654, 66792, 80602, 63493, 63469, 54202, 53325, 54781, 55133, 55262, 56869, 59866, 63406, 63407, 63410, 63470, 63468, 72979, 78746, 69391, 72918, 77365, 79851, 79138, 79620, 79448, 79794, 80590, 80857, 82104, 82369, 82945, 89329, 89427, 77547, 145335);
delete from person_name where person_id in (56873, 59966, 78712, 54797, 56071, 56455, 56500, 56499, 57975, 58531, 59177, 59654, 66792, 80602, 63493, 63469, 54202, 53325, 54781, 55133, 55262, 56869, 59866, 63406, 63407, 63410, 63470, 63468, 72979, 78746, 69391, 72918, 77365, 79851, 79138, 79620, 79448, 79794, 80590, 80857, 82104, 82369, 82945, 89329, 89427, 77547, 145335);
delete from person_address where person_id in (56873, 59966, 78712, 54797, 56071, 56455, 56500, 56499, 57975, 58531, 59177, 59654, 66792, 80602, 63493, 63469, 54202, 53325, 54781, 55133, 55262, 56869, 59866, 63406, 63407, 63410, 63470, 63468, 72979, 78746, 69391, 72918, 77365, 79851, 79138, 79620, 79448, 79794, 80590, 80857, 82104, 82369, 82945, 89329, 89427, 77547, 145335);
delete from person_attribute where person_id in (56873, 59966, 78712, 54797, 56071, 56455, 56500, 56499, 57975, 58531, 59177, 59654, 66792, 80602, 63493, 63469, 54202, 53325, 54781, 55133, 55262, 56869, 59866, 63406, 63407, 63410, 63470, 63468, 72979, 78746, 69391, 72918, 77365, 79851, 79138, 79620, 79448, 79794, 80590, 80857, 82104, 82369, 82945, 89329, 89427, 77547, 145335);
delete from person where person_id in (56873, 59966, 78712, 54797, 56071, 56455, 56500, 56499, 57975, 58531, 59177, 59654, 66792, 80602, 63493, 63469, 54202, 53325, 54781, 55133, 55262, 56869, 59866, 63406, 63407, 63410, 63470, 63468, 72979, 78746, 69391, 72918, 77365, 79851, 79138, 79620, 79448, 79794, 80590, 80857, 82104, 82369, 82945, 89329, 89427, 77547, 145335);

-- GAN207175
insert into event_records (uuid, title, timestamp, object, category)
values('f26b8e2c-5ff9-4d54-a8d6-ce7bb1de5e50', 'Patient', now(), '/openmrs/ws/rest/v1/patient/f26b8e2c-5ff9-4d54-a8d6-ce7bb1de5e50?v=full', 'patient');

-- GAN207248
insert into event_records (uuid, title, timestamp, object, category)
values('08c6b3e9-f5bc-446b-9e33-4f9e3421b08d', 'Patient', now(), '/openmrs/ws/rest/v1/patient/08c6b3e9-f5bc-446b-9e33-4f9e3421b08d?v=full', 'patient');

-- GAN207330
insert into event_records (uuid, title, timestamp, object, category)
values('ec9dfac2-f4a2-4a8e-97df-f8ad99d140a3', 'Patient', now(), '/openmrs/ws/rest/v1/patient/ec9dfac2-f4a2-4a8e-97df-f8ad99d140a3?v=full', 'patient');

-- GAN207656
insert into event_records (uuid, title, timestamp, object, category)
values('76f89905-5fc9-446d-abc8-9818a3e816ef', 'Patient', now(), '/openmrs/ws/rest/v1/patient/76f89905-5fc9-446d-abc8-9818a3e816ef?v=full', 'patient');

-- GAN208096
insert into event_records (uuid, title, timestamp, object, category)
values('21a79ff7-c0e5-4f88-b146-46b9a672aca4', 'Patient', now(), '/openmrs/ws/rest/v1/patient/21a79ff7-c0e5-4f88-b146-46b9a672aca4?v=full', 'patient');

-- GAN208310
insert into event_records (uuid, title, timestamp, object, category)
values('9cfcd0bb-9e8f-41a1-91c5-83843df2a846', 'Patient', now(), '/openmrs/ws/rest/v1/patient/9cfcd0bb-9e8f-41a1-91c5-83843df2a846?v=full', 'patient');
