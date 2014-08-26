#!/bin/sh -x
PATH_OF_CURRENT_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $PATH_OF_CURRENT_SCRIPT/vagrant/vagrant_functions.sh

sh $PATH_OF_CURRENT_SCRIPT/vagrant-copy-migrations.sh
run_in_vagrant -c "sudo su - jss -c 'cd /bahmni_temp/ && ./run-implementation-liquibase.sh'"
