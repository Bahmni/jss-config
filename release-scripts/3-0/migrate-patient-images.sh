#!/bin/sh
set -e
HOME_DIR=/home/jss
IMAGES_DIR=${HOME_DIR}/patient_images
BKUP_FILE=${HOME_DIR}/patient_images_bkup-`date +%Y-%m-%d-%k%M%s`.tar.gz
tar -zcvf  ${BKUP_FILE} $IMAGES_DIR
echo "Backed up all patient images in ${BKUP_FILE}"


UUID_LOOKUP_FILE=/tmp/uuid-to-patientid.csv
mysql -uopenmrs-user -ppassword -Dopenmrs > ${UUID_LOOKUP_FILE} <<EOF
select concat(pi.identifier, ',' , p.uuid)
	from patient_identifier pi 
	join person p 
		on p.person_id = pi.patient_id;
EOF

for file in `ls $IMAGES_DIR` 
do
	LOOKUP_VAR=`echo $file | cut -f1 -d'.'`,
	UUID=`grep $LOOKUP_VAR $UUID_LOOKUP_FILE | cut -f2 -d','`
	if [ "${UUID}a" != "a" ]
	then
		mv ${IMAGES_DIR}/$file ${IMAGES_DIR}/${UUID}.jpeg
	else 
		echo "Could not find a matching uuid for ${IMAGES_DIR}/$file"
	fi
done

echo "All set"