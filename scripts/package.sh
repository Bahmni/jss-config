
#!/bin/bash

BASE_DIR=`dirname $0`
ROOT_DIR=$BASE_DIR/..

mkdir -p $ROOT_DIR/target
rm -rf $ROOT_DIR/target/jss_config.zip

$BASE_DIR/validate-json.sh $ROOT_DIR/openmrs
if [[ $? -eq 0 ]]
    then
        cd $ROOT_DIR && zip -r target/jss_config.zip openmrs/* migrations/* openelis/* openerp/*
    else
        echo "Validation failed. Please fix the errors and try again"
        exit 1
fi
