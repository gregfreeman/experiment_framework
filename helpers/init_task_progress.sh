#!/bin/bash

usage()
{
cat << EOF
usage: $0 experiment tasks email

starts a new experiment with a number of tasks and email


EOF
}


URL=http://experiment-framework.appspot.com/
#URL=http://localhost:8080/
NAME=$1
TASKS=$2
EMAIL=$3
echo "{\"name\":\"${NAME}\", \"tasks\":${TASKS}, \"email\":\"${EMAIL}\"}"
echo "{\"name\":\"${NAME}\", \"tasks\":${TASKS}, \"email\":\"${EMAIL}\"}" | curl -X POST -H 'Content-type: application/json' -d @- ${URL}start

