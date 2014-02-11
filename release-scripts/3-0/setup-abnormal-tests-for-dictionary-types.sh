#!/bin/sh

# initial count of test_result having abnormal dict value
psql -Uclinlims clinlims > /tmp/test <<EOF
select count(*) from test_result where abnormal=true and tst_rslt_type = 'D';
EOF
initialAbnormalResult=`sed -n '3p' /tmp/test`;

# updating test_result according to the csv
counter=0
abnormalValuesFromCSV=0
IFS=","
while read testname dict_entry abnormal dummy
do	
if [ "$testname" != "" -a "$dict_entry" != "" -a "$abnormal" != "" ]
then
testname=\'$testname\'
dict_entry=\'$dict_entry\'
abnormal=\"$abnormal\"
value=false
if [ "$abnormal" = "\"Abnormal\"" ]; then
	value=true
	abnormalValuesFromCSV=$((abnormalValuesFromCSV+1))
fi

echo "$testname $dict_entry is $value"
psql -Uclinlims clinlims <<END_SQL
update test_result set abnormal = $value where id = (SELECT distinct tr.id
FROM dictionary d join test_result tr on CAST (tr.value AS INTEGER) = d.id
join test t on t.id = tr.test_id
where tr.tst_rslt_type = 'D' and t.name = $testname and d.dict_entry = $dict_entry);		
END_SQL

counter=$((counter+1))
fi
done < testsWithDictionaryValues.csv

echo "$counter rows updated in test results"

# count of test_result having abnormal as true after update
psql -Uclinlims clinlims > /tmp/test <<EOF
select count(*) from test_result where abnormal=true;
EOF
abnormalDictValues=`sed -n '3p' /tmp/test`;

echo "db- no of abnormal test_result before update : " $initialAbnormalResult;
echo "db- no of abnormal test_result after update  : " $abnormalDictValues;

echo "Out of $counter, $abnormalValuesFromCSV was abnormal"
echo "expected result is 289 and abnormal is 188"


