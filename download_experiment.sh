#!/bin/bash

usage()
{
cat << EOF
usage: $0 experiment options

copies the experiment results via scp
experiment is the experiment name

OPTIONS:
   -g      Copy the gradient data
   -e      Copy the exact line search data
   -f      final results compilation and paramset.mat
   -b      Copy the backtracking line search data
   -i      Copy image data
   -s      Copy settings data
   -x      do not copy default experiment data (results*.mat and paramset.mat)
   -?      show this message
   -h      show this message

Configuration:
uses git config files

[experimentframework]
	remoteresults = user@machine:~/some/path
	localresults = /unix/or/cygwin/path


EOF
}

GRAD=0
ELINE=0
BTLINE=0
IMAGE=0
DEFAULT=1
SETTING=0
FINAL=0
while getopts "gebixh" OPTION
do
     echo "Has parameter $OPTION"
			
     case $OPTION in
         g)
             GRAD=1
             ;;
         e)
             ELINE=1
             ;;
         b)
             BTLINE=1
             ;;
         i)
             IMAGE=1
             ;;
         i)
             SETTING=1
             ;;
		 f)
		     FINAL=1;
			 DEFAULT=0;     
			 ;;
         x)
             DEFAULT=0
             ;;
         h)
             usage
             exit 1
             ;;
         ?)
             usage
          	 echo "Parameter $OPTION not valid"
             exit 1
             ;;
     esac
done
shift $(($OPTIND - 1))
EXPERIMENT=$1


REMOTE=`git config  experimentframework.remoteresults`
BASE_PATH=`git config experimentframework.localresults`


if [ -z "$REMOTE" ]; then
    echo "experimentframework.remoteresults not found. please add to git config."
    echo "ie: git config experimentframework.remoteresults user@machine:~/some/path"
fi

if [ -z "$BASE_PATH" ]; then
    echo "experimentframework.remoteresults not found. please add to git config."
    echo "ie: git config experimentframework.remoteresults user@machine:~/some/path"
fi


echo "Downloading Experiment: ${EXPERIMENT}"

if [ ! -d "${BASE_PATH}${EXPERIMENT}" ]
then
  mkdir  ${BASE_PATH}${EXPERIMENT}
fi

if [ $DEFAULT -eq 1 ]
then
  scp ${REMOTE}${EXPERIMENT}/paramset.mat  ${BASE_PATH}${EXPERIMENT}
  scp ${REMOTE}${EXPERIMENT}/results*.mat  ${BASE_PATH}${EXPERIMENT}
fi

if [ $FINAL -eq 1 ]
then
  scp ${REMOTE}${EXPERIMENT}/paramset.mat  ${BASE_PATH}${EXPERIMENT}
  scp ${REMOTE}${EXPERIMENT}/results.mat  ${BASE_PATH}${EXPERIMENT}
fi


if [ $GRAD -eq 1 ]
then
  scp ${REMOTE}${EXPERIMENT}/case_*_gradient_comp_*.mat      ${BASE_PATH}${EXPERIMENT}
fi

if [ $ELINE -eq 1 ]
then
  scp ${REMOTE}${EXPERIMENT}/case_*_exact_line_search_*.mat  ${BASE_PATH}${EXPERIMENT}
fi

if [ $BTLINE -eq 1 ]
then
  scp ${REMOTE}${EXPERIMENT}/case_*_bt_line_search_*.mat     ${BASE_PATH}${EXPERIMENT}
fi
  
if [ $IMAGE -eq 1 ]
then
  scp ${REMOTE}${EXPERIMENT}/image_*.png         ${BASE_PATH}${EXPERIMENT}
fi

if [ $SETTING -eq 1 ]
then
  scp ${REMOTE}${EXPERIMENT}/settings_*.mat     ${BASE_PATH}${EXPERIMENT}
fi
   