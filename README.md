Experiment Framework
====================================

This code collection provides a framework for running experiments in MATLAB with mulitple cases and analysing the results

Installation
------------

The framework requires MATLAB.  

Optional: create a setup_custom.m file from the setup_custom_default.m file to specify settings of your environment
the custom setup allows specifying the location of output files and the number of paralell processes to concurrently run.


Gettings Started
----------------

Open MATLAB

run the setup script
    setup_experiment_framework

run an experiment script


Customize
------------
copy setup_custom_default.m  to setup_custom.m  (this file will be loaded from setup_experiment_framework)

global variables
% DATA_PATH___ store the location of the input data file
% DATA_PATH___='c:\Data';
% DATA_PATH___='~/data';

%RESULT_ROOT___ specifies the path were output is sent.  This defaults to
%the local results folder.  output files can be large.  This allows storing
%output files in a location that has free space.
%RESULT_ROOT___='/misc/scratch/gfreeman/results';


% MATLAB_REMOTE_PATH___ specifies the matlab path when running tests
% remotely
% MATLAB_REMOTE_PATH___='/usr/local/packages/matlab_2010a/bin/matlab';

Distributed (I really mean embarrassingly parrallel on one machine)
------------

Allows dividing experiments between multiple processors.

define global variables in setup_custom.m 

overriding testRunnerFunc function pointer for distributed processes 

	MAX_PROCESSES___=1;
	testRunnerFunc=@(paramset,events,basepath_name) testRunnerDistributed(paramset,events,basepath_name,MAX_PROCESSES___);


example:
	[ret, machinename] = system('hostname');
	switch strtrim(machinename)
	case {'luigi.ece.utexas.edu','thwomp.ece.utexas.edu'} % 16x4 core Intel Zeon 2.8GHz 64GB
	   MAX_PROCESSES___=12;
	case {'mario','daisy'}  % 4x2 core Intel Zeon 3Ghz  16GB
	   MAX_PROCESSES___=4;
	case {'bowser.ece.utexas.edu','peach.ece.utexas.edu'}  % 8x4 core AMD 2.4Ghz  32GB
	   MAX_PROCESSES___=8;
	case {'yoshi.ece.utexas.edu'} % 8x4 core  800Mhz  32GB
	   MAX_PROCESSES___=8;
	end






