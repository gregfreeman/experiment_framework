#!/bin/bash

usage()
{
cat << EOF
usage: $0 experiment task progress

updates the experiment progress

EOF
}


#URL=http://localhost:8080/
URL=http://experiment-framework.appspot.com/
NAME=$1
TASK=$2
PROGRESS=$3
echo "{\"name\":\"${NAME}\", \"task_num\":${TASK}, \"progress\":\"${PROGRESS}\"}"
echo "{\"name\":\"${NAME}\", \"task_num\":${TASK}, \"progress\":\"${PROGRESS}\"}" | curl -X POST -H 'Content-type: application/json' -d @- ${URL}update

