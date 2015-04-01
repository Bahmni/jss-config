select * from location;
select * from location_tag;
select * from location_tag_map;
select * from bed_type;
select * from bed;
select * from bed_location_map;
select * from bed_patient_assignment_map;

insert into location_tag (name, description, creator, retired, date_created, uuid) values('Admission Location', 'General Ward Patients', 2, 0, NOW(), UUID());
SET @location_tag_id = (select location_tag_id from location_tag where name='Admission Location');

insert into bed_type values(1, 'normal', 'normal bed', 'NRM');
insert into bed_type values(2, 'extra', 'extra bed', 'EXT');

# ICU WARD
insert into location (name, description, creator, retired, date_created, uuid) values('ICU Physical Location', 'ICU Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='ICU Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);

insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('ICU', 'ICU', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='ICU');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(1, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(2, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(3, '3', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(4, '4', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(5, '5', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(1, @location_id, 1, 1, 1);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(2, @location_id, 1, 2, 2);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(3, @location_id, 1, 3, 3);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(4, @location_id, 1, 4, 4);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(5, @location_id, 2, 1, 5);

# WARD 1

insert into location (name, description, creator, retired, date_created, uuid) values('Ward 1 Physical Location', 'Ward 1 Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='Ward 1 Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);

insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('Ward 1', 'Ward 1', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='Ward 1');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(6, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(7, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(8, '3', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(9, '4', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(10, '5', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(11, '6', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(12, '7', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(6, @location_id, 1, 1, 6);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(7, @location_id, 1, 2, 7);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(8, @location_id, 1, 3, 8);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(9, @location_id, 1, 4, 9);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(10, @location_id, 2, 1, 10);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(11, @location_id, 2, 2, 11);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(12, @location_id, 2, 3, 12);

# WARD 1A
insert into location (name, description, creator, retired, date_created, uuid) values('Ward 1A Physical Location', 'Ward 1A Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='Ward 1A Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);

insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('Ward 1A', 'Ward 1A', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='Ward 1A');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(13, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(14, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(15, '3', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(16, '4', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(17, '5', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(13, @location_id, 1, 1, 13);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(14, @location_id, 1, 2, 14);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(15, @location_id, 1, 3, 15);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(16, @location_id, 1, 4, 16);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(17, @location_id, 2, 1, 17);

# WARD 2

insert into location (name, description, creator, retired, date_created, uuid) values('Ward 2 Physical Location', 'Ward 2 Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='Ward 2 Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);

insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('Ward 2', 'Ward 2', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='Ward 2');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(18, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(19, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(20, '3', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(21, '4', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(22, '5', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(23, '6', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(24, '7', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(25, '8', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(26, '9', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(27, '10', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(28, '11', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(29, '12', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(30, '13', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(31, '14', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(32, '15', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(33, '16', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(34, '17', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(35, '18', 'AVAILABLE', 2, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(36, '19', 'AVAILABLE', 2, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(37, '20', 'AVAILABLE', 2, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(18, @location_id, 1, 1, 18);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(19, @location_id, 1, 2, 19);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(20, @location_id, 1, 3, 20);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(21, @location_id, 1, 4, 21);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(22, @location_id, 2, 1, 22);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(23, @location_id, 2, 2, 23);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(24, @location_id, 2, 3, 24);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(25, @location_id, 2, 4, 25);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(26, @location_id, 3, 1, 26);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(27, @location_id, 3, 2, 27);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(28, @location_id, 3, 3, 28);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(29, @location_id, 3, 4, 29);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(30, @location_id, 4, 1, 30);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(31, @location_id, 4, 2, 31);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(32, @location_id, 4, 3, 32);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(33, @location_id, 4, 4, 33);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(34, @location_id, 5, 1, 34);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(35, @location_id, 5, 2, 35);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(36, @location_id, 5, 3, 36);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(37, @location_id, 5, 4, 37);

# WARD 3

insert into location (name, description, creator, retired, date_created, uuid) values('Ward 3 Physical Location', 'Ward 3 Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='Ward 3 Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);

insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('Ward 3', 'Ward 3', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='Ward 3');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(38, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(39, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(40, '3', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(41, '4', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(42, '5', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(43, '6', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(44, '7', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(38, @location_id, 1, 1, 38);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(39, @location_id, 1, 2, 39);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(40, @location_id, 1, 3, 40);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(41, @location_id, 1, 4, 41);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(42, @location_id, 2, 1, 42);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(43, @location_id, 2, 2, 43);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(44, @location_id, 2, 3, 44);

# New OPD
insert into location (name, description, creator, retired, date_created, uuid) values('New OPD Physical Location', 'New OPD Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='New OPD Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);

insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('New OPD', 'New OPD', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='New OPD');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(45, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(46, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(45, @location_id, 1, 1, 45);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(46, @location_id, 1, 2, 46);

# OPD 5

insert into location (name, description, creator, retired, date_created, uuid) values('OPD 5 Physical Location', 'OPD 5 Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='OPD 5 Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);

insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('OPD 5', 'OPD 5', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='OPD 5');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(47, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(48, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(49, '2', 'AVAILABLE', 2, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(47, @location_id, 1, 1, 47);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(48, @location_id, 1, 2, 48);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(49, @location_id, 1, 3, 49);

# OPD 6

insert into location (name, description, creator, retired, date_created, uuid) values('OPD 6 Physical Location', 'OPD 6 Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='OPD 6 Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);


insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('OPD 6', 'OPD 6', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='OPD 6');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(50, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(51, '2', 'AVAILABLE', 2, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(50, @location_id, 1, 1, 50);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(51, @location_id, 1, 2, 51);

# NICU

insert into location (name, description, creator, retired, date_created, uuid) values('NICU Physical Location', 'NICU Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='NICU Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);

insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('NICU', 'NICU', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='NICU');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(52, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(53, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(54, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(55, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(52, @location_id, 1, 1, 52);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(53, @location_id, 1, 2, 53);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(54, @location_id, 1, 3, 54);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(55, @location_id, 1, 4, 55);

# Paediatric Ward

insert into location (name, description, creator, retired, date_created, uuid) values('Pediatric Physical Location', 'Pediatric Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='Pediatric Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);


insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('Paediatric Ward', 'Paediatric Ward', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='Paediatric Ward');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(56, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(57, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(58, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(59, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(56, @location_id, 1, 1, 56);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(57, @location_id, 1, 2, 57);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(58, @location_id, 1, 3, 58);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(59, @location_id, 1, 4, 59);

# TB Ward
insert into location (name, description, creator, retired, date_created, uuid) values('TB Ward Physical Location', 'TB Ward Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='TB Ward Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);


insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('TB Ward', 'TB Ward', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='TB Ward');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(60, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(61, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(62, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(63, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(60, @location_id, 1, 1, 60);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(61, @location_id, 1, 2, 61);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(62, @location_id, 1, 3, 62);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(63, @location_id, 1, 4, 63);

# TB Isolation
insert into location (name, description, creator, retired, date_created, uuid) values('TB Isolation Physical Location', 'TB Isolation Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='TB Isolation Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);


insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('TB Isolation', 'TB Isolation', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='TB Isolation');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(64, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(65, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(66, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(64, @location_id, 1, 1, 64);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(65, @location_id, 1, 2, 65);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(66, @location_id, 1, 3, 66);

# Staff Ward

insert into location (name, description, creator, retired, date_created, uuid) values('Staff Ward Physical Location', 'Staff Ward Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='Staff Ward Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);


insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('Staff Ward', 'Staff Ward', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='Staff Ward');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(67, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(67, @location_id, 1, 1, 67);

# Dharamshala
insert into location (name, description, creator, retired, date_created, uuid) values('Dharamshala Physical Location', 'Dharamshala Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='Dharamshala Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);


insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('Dharamshala', 'Dharamshala', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='Dharamshala');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(68, '2', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(69, '3', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(70, '4', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(71, '5', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(72, '6', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(73, '7', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(74, '8', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(75, '9', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(76, '10', 'AVAILABLE', 1, UUID(), 1, NOW(), false);
insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(77, '10', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(68, @location_id, 1, 1, 68);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(69, @location_id, 1, 2, 69);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(70, @location_id, 1, 3, 70);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(71, @location_id, 1, 4, 71);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(72, @location_id, 2, 1, 72);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(73, @location_id, 2, 2, 73);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(74, @location_id, 2, 3, 74);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(75, @location_id, 2, 4, 75);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(76, @location_id, 3, 1, 76);
insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(77, @location_id, 3, 2, 77);

# ANC
insert into location (name, description, creator, retired, date_created, uuid) values('ANC Physical Location', 'ANC Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='ANC Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);

insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('ANC', 'ANC', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='ANC');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(78, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(78, @location_id, 1, 1, 78);

# OT RR
insert into location (name, description, creator, retired, date_created, uuid) values('OT RR Physical Location', 'OT RR Physical Location', 1, 0, NOW(), UUID());
SET @parent_location_id = (select location_id from location where name='OT RR Physical Location');
insert into location_tag_map values( @parent_location_id , @location_tag_id);

insert into location (name, description, creator, retired, date_created, uuid, parent_location) values('OT RR', 'OT RR', 1, 0, NOW(), UUID(), @parent_location_id);
SET @location_id = (select location_id from location where name='OT RR');

insert into location_tag_map values( @location_id , @location_tag_id);


insert into bed (bed_id, bed_number, status, bed_type_id, uuid, creator, date_created, voided) values(79, '1', 'AVAILABLE', 1, UUID(), 1, NOW(), false);

insert into bed_location_map(bed_location_map_id, location_id, row_number, column_number, bed_id) values(79, @location_id, 1, 1, 79);

