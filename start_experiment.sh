#!/bin/bash -i

usage()
{
cat << EOF
usage: $0 options experiment host

starts an experiment on a remote machine via ssh

OPTIONS:
   -?      show this message
   -h      show this message

Configuration:
uses git config files

[experimentframework]
	remotematlab = /path/to/matlab/bin/matlab
	remotepath = ~/path/to/remote/experiment
	startupcommand = setup_study
	remotemachine = user@machine
	remotecommand = ssh $(REMOTEMACHINE) "$(REMOTEMATLAB) -nodisplay -r \"cd '$(REMOTEPATH)';$(STARTUPCOMMAND);$(EXPERIMENTNAME);exit\" "

Examples:
To use detault machine: 	    $0 myexperiment 
To start on a specific machine:	$0 myexperiment user@machine

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

EXPERIMENTNAME=$1
REMOTEMACHINE=$2

if [ -z "$REMOTEMACHINE" ]; then
	REMOTEMACHINE=`git config experimentframework.remotemachine`
fi

REMOTEMATLAB=`git config experimentframework.remotematlab`
STARTUPCOMMAND=`git config experimentframework.startupcommand`
REMOTEPATH=`git config experimentframework.remotepath`


if [ -z "$REMOTEMACHINE" ]; then
    echo "experimentframework.remoteresults not found. please add to git config or as a command line parameter."
    echo "ie: git config experimentframework.remoteresults user@machine"
fi

if [ -z "$REMOTEMATLAB" ]; then
    echo "experimentframework.remotematlab not found. please add to git config."
    echo "ie: git config experimentframework.remotematlab /path/to/matlab/bin/matlab "
fi

if [ -z "$STARTUPCOMMAND" ]; then
    echo "experimentframework.startupcommand not found. please add to git config."
    echo "ie: git config experimentframework.startupcommand setup_study;"
fi

echo "Starting Experiment: ${EXPERIMENTNAME}"
echo "Starting command: ${STARTUPCOMMAND}"
echo "Remote machine: ${REMOTEMACHINE}"
echo "Remote path: ${REMOTEPATH}"
echo "Remote matlab: ${REMOTEMATLAB}"
#set -x	
COMMAND="screen ${REMOTEMATLAB} -nodisplay -r \"cd '${REMOTEPATH}';${STARTUPCOMMAND};${EXPERIMENTNAME};exit\" "
echo ssh $REMOTEMACHINE -t "`echo $COMMAND`"
ssh $REMOTEMACHINE -t "`echo $COMMAND`"
