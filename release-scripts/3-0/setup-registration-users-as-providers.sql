insert into provider (person_id, name, identifier, creator, date_created, uuid) 
	select person_id, username, username, creator, now(), uuid() 
	from users 
	where user_id in (
		select user_id from user_role where role = 'RegistrationClerk');