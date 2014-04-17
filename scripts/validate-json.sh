#!/bin/bash

SEARCH_DIR=$1
if [[ -z "$1" ]]
then
    SEARCH_DIR=`pwd`
fi

#http://www.cyberciti.biz/tips/handling-filenames-with-spaces-in-bash.html
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

exit_code=0
echo "$(tput setaf 7)************ JSON validation start ************"

for file_name in `find $SEARCH_DIR -name "*.json"`
do
    python -m json.tool "$file_name" 1> /dev/null 2> temp_json_parser_error.txt
    if [[ $? -eq 0 ]]
        then
            echo "$(tput setaf 2)[PASSED] $file_name"
        else
            echo "$(tput setaf 1)[FAILED] $file_name$(tput setaf 5)"
            cat temp_json_parser_error.txt
            exit_code=1
    fi
done
IFS=$SAVEIFS
echo "$(tput setaf 7)************ JSON validation end ************"

if [[ -f temp_json_parser_error.txt ]]; then rm temp_json_parser_error.txt; fi
exit $exit_code