DELIMITER $$

CREATE PROCEDURE add_user (username VARCHAR(255))
BEGIN

  DECLARE puuid VARCHAR(255);
  DECLARE _salt VARCHAR(255);
  DECLARE _password VARCHAR(255);
  DECLARE _user_id VARCHAR(255);

  select salt, password from users where system_id = 'admin' into _salt, _password;

  SELECT uuid() into puuid;
  insert into person(birthdate_estimated, dead, creator, date_created, uuid) values(0, 0, 1, now(), puuid);

  insert into users(system_id, creator, date_created, person_id, uuid, username, password, salt)
  values (username, 1, now(),(select person_id from person where uuid = puuid) , uuid(), username, _password, _salt);

  select max(user_id) from users into _user_id;

  insert into user_role(user_id, role) values(_user_id, 'Provider');
  insert into user_role(user_id, role) values(_user_id, 'System Developer');
  insert into user_role(user_id, role) values(_user_id, 'bahmni-document-uploader');
  insert into user_role(user_id, role) values(_user_id, 'EmergencyRegistration');
  insert into user_role(user_id, role) values(_user_id, 'RegistrationClerk');
  insert into user_role(user_id, role) values(_user_id, 'Anonymous');
  insert into user_role(user_id, role) values(_user_id, 'Authenticated');
  insert into user_role(user_id, role) values(_user_id, 'Privilege Level: Full');

  insert into provider (person_id, identifier, creator, date_created, uuid, name)
  values ((select person_id from person where uuid = puuid), '', 1, now(), uuid(), username);

END;
