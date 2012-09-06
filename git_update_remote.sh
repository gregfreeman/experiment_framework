#!/bin/bash

usage()
{
cat << EOF
usage: $0 options 

update remote git repository and submodules

OPTIONS:
   -?      show this message
   -h      show this message

Configuration:
uses git config files

[experimentframework]
	remotepath = ~/path/to/remote/experiment
	remotemachine = user@machine


EOF
}

while getopts "gebixh" OPTION
do
     echo "Has parameter $OPTION"
			
     case $OPTION in
			
         ?)
             usage
          	 echo "Parameter $OPTION not valid"
             exit 1
             ;;
     esac
done
shift $(($OPTIND - 1))

REMOTEMACHINE=`git config experimentframework.remotemachine`
REMOTEPATH=`git config experimentframework.remotepath`


if [ -z "$REMOTEMACHINE" ]; then
    echo "experimentframework.remoteresults not found. please add to git config or as a command line parameter."
    echo "ie: git config experimentframework.remoteresults user@machine"
fi

if [ -z "$REMOTEPATH" ]; then
    echo "experimentframework.remotepath not found. please add to git config."
    echo "ie: git config experimentframework.remotepath ~/path/to/remote/experiment "
fi

echo "Remote machine: ${REMOTEMACHINE}"
echo "Remote path: ${REMOTEPATH}"

COMMAND="cd ${REMOTEPATH};git pull origin master;git submodule init;git submodule sync;git submodule update;"
echo "Command: $COMMAND"

echo "ssh $REMOTEMACHINE \"${COMMAND}\""
echo ssh $REMOTEMACHINE \"${COMMAND}\"
ssh $REMOTEMACHINE "${COMMAND}"
