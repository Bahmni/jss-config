delete from patient_identity where patient_id in (select id from patient where uuid in ('412c5f11-4062-494a-927d-f981e3e900b3', '29afa5ba-a890-4fab-8b6a-2c2386f52f71', '3e800bc5-1245-4b21-b39f-025d518fe956', 
'c45b263f-64b7-4b00-a297-d8fe6223f099', '93e98a69-08d6-461b-b09d-444c7a650786', '427a1399-8428-4697-a24f-d69776c9d7bb', '09cf3d51-5016-420a-a743-cd938107871d'));

-- no person_address , hence no delete 

delete from patient where uuid in ('412c5f11-4062-494a-927d-f981e3e900b3', '29afa5ba-a890-4fab-8b6a-2c2386f52f71', '3e800bc5-1245-4b21-b39f-025d518fe956', 
'c45b263f-64b7-4b00-a297-d8fe6223f099', '93e98a69-08d6-461b-b09d-444c7a650786', '427a1399-8428-4697-a24f-d69776c9d7bb', '09cf3d51-5016-420a-a743-cd938107871d');

delete from person where id in (150993, 151104, 151825, 152025, 152066, 151997, 152669 );

update patient set uuid = '412c5f11-4062-494a-927d-f981e3e900b3' where id = (select patient_id from patient_identity where identity_data = 'BAM12497');
update patient set uuid = '29afa5ba-a890-4fab-8b6a-2c2386f52f71' where id = (select patient_id from patient_identity where identity_data = 'BAM12797');
update patient set uuid = '3e800bc5-1245-4b21-b39f-025d518fe956' where id = (select patient_id from patient_identity where identity_data = 'BAM16371');
update patient set uuid = 'c45b263f-64b7-4b00-a297-d8fe6223f099' where id = (select patient_id from patient_identity where identity_data = 'BAM16373');
update patient set uuid = '93e98a69-08d6-461b-b09d-444c7a650786' where id = (select patient_id from patient_identity where identity_data = 'BAM16375');
update patient set uuid = '427a1399-8428-4697-a24f-d69776c9d7bb' where id = (select patient_id from patient_identity where identity_data = 'BAM16381');
update patient set uuid = '09cf3d51-5016-420a-a743-cd938107871d' where id = (select patient_id from patient_identity where identity_data = 'BAM429'  );