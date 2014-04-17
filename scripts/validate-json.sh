#!/bin/bash

SEARCH_DIR=$1
if [[ -z "$1" ]]
then
    SEARCH_DIR=`pwd`
fi

echo "$(tput setaf 7)"
exit_code=0

#http://www.cyberciti.biz/tips/handling-filenames-with-spaces-in-bash.html
find $SEARCH_DIR -iname "*.json" -print0 | while read -d $'\0' file_name
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
echo "$(tput setaf 7)"

if [[ -f temp_json_parser_error.txt ]]; then rm temp_json_parser_error.txt; fi

exit $exit_code