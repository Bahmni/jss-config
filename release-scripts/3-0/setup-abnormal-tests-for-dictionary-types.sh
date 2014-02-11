#!/bin/sh
counter=0
IFS=","
while read testname dict_entry abnormal
do
if [ "$testname" != "" -a "$dict_entry" != "" -a "$abnormal" != "" ]
then
testname=\'$testname\'
dict_entry=\'$dict_entry\'
value=false
if [ "$abnormal" == "Abnormal" ]; then
	value=true
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