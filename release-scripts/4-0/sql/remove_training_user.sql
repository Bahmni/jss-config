DELIMITER $$

CREATE PROCEDURE remove_user (_username VARCHAR(255))
BEGIN

  DECLARE _person_id INT;
  DECLARE _user_id INT;

  select person_id from users where username = _username limit 1 into _person_id;
  select user_id from users where username = _username limit 1 into _user_id;

  delete from provider where person_id = _person_id;
  delete from user_property where user_id = _user_id;
  delete from user_role where user_id = _user_id;
  delete from users where person_id = _person_id;
  delete from person_name where person_id = _person_id;
  delete from person where person_id = _person_id;
  
END
