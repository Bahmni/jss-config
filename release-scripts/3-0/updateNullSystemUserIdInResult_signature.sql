update result_signature set system_user_id= (select id from system_user where login_name='admin') where non_user_name='0';

update result_signature set system_user_id= (select id from system_user where login_name='asha') where non_user_name='AshAa Kaushik';