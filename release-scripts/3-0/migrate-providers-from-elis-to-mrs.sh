#!/bin/sh

psql -Uclinlims clinlims  <<END_SQL
		update system_user set external_id = uuid_generate_v4() where external_id = '1'; 
END_SQL

POSTGRES_UUID_LOOKUP_FILE=/tmp/postgres-uuid-to-login-name.csv

psql -d clinlims -Uclinlims -t -A -F"," -c "select external_id, login_name from system_user" > ${POSTGRES_UUID_LOOKUP_FILE}

IFS=","
while read f1 f2
do
if [ "${f1}" != "" -a "${f2}" != "" ]
then
f1=\'$f1\'
f2=\'$f2\'
mysql -uopenmrs-user -ppassword -Dopenmrs <<END_SQL
		insert into provider (name, identifier, creator, date_created, retired,uuid) values ($f2, $f2, 1, now(), 0, $f1);
END_SQL
fi
done < $POSTGRES_UUID_LOOKUP_FILE

echo "All set"