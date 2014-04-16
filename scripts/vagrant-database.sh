#!/bin/sh -x
PATH_OF_CURRENT_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $PATH_OF_CURRENT_SCRIPT/vagrant/vagrant_functions.sh

run_in_vagrant -c "sudo rm -rf /packages/build/jss_config/migrations/*"
run_in_vagrant -c "sudo mkdir -p /packages/build/jss_config/migrations"
run_in_vagrant -c "sudo chown jss:jss /packages/build/jss_config/migrations"
run_in_vagrant -c "sudo su - jss -c 'cp /Project/jss-config/migrations/* /packages/build/jss_config/migrations/'"
run_in_vagrant -c "sudo su - jss -c 'cd /bahmni_temp/ && ./run-implementation-liquibase.sh'"
