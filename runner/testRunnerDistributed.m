function [foldername]=testRunnerDistributed(paramset,events,basepath_name,max_processes)
% resultsCollection=testRunner(paramset,events,basepath_name)
%TESTRUNNERDISTRIBUTED runs an experiment that include one of more test cases
% Test cases are run with multiple processes.
% This function only works on linux based operating systems
% input:
%   paramset:  defines all parameters for an experiment
%      an array of structures with fields:
%        name: specifies a parameter name
%        values: cell array of the values for the parameter
%   events: defines a set of activities that are run during the test.
%     events include:
%     (required)  [inputData,settings]=events.loadInputData(settings)   
%     (required)  [outputData,results]=events.runExperiment(inputData,settings)  
%     (optional)  results=events.evaluateMetrics(results,inputData,outputData)  
%     (optional)  events.storeOutputData(outputData, inputData, links)
%                       links is an object with an add method
%                       fullpath=links.add(name,ext) 
%                         returns a path to a numbered file 
%                         with a base name and extension in
%                         the experiments results folder.
%     (optional)  events.startTasks(foldername,tasks)
%     (optional)  events.updateTask(foldername,task_num,done,total)
%
%   basepath_name: defines the base path for the folder in which experiment files
%   will be generated.  If basepath_name is empty or not specified, this
%   defaults to the name and location of the mfile calling this one.
%   max_processes: defines the max number of processes to start
% 
%  
% output:
%   the function will spawn the processes and return immediately
% output files:
%   settings000.mat - a file for each test case.
%   paramset.mat - a stores a copy of the paramset array.
%   results000.mat - a file storing an individual test results
%   launch.sh - the script file which launches the processes

global MATLAB_REMOTE_PATH___

if ~isunix
    error('testRunnerDistributed only works on unix based operating systems');
end

if ~exist('basepath_name','var')
    basepath_name=[];
end

if ~exist('max_processes','var')
     error('max_processes not defined');
end

setup_command='setup';
if isfield(events,'setup_command')
    setup_command=events.setup_command;
end 

basepath_name=testRunnerFolder(basepath_name);
disp '********************************************************'
disp 'Setting up experiments'
[nCases,foldername]=testRunnerSetup(basepath_name,paramset,events);
disp(['Foldername: ' foldername])

processes=min(nCases,max_processes);

if isfield(events,'startTasks')
    events.startTasks(foldername, processes);
end 


idx=find(basepath_name == filesep);
name = basepath_name(idx(end)+1:end);

script_name=[foldername '/launch.sh'];
f=fopen(script_name,'w');
fprintf(f,'#!/bin/bash\n');
for iProc=1:processes
    range=sprintf('%d:%d:%d',iProc,processes,nCases);
    name_i=[name '_proc' num2str(iProc)];
    command=sprintf('screen -L -d -t %s -m %s -nodisplay -r "%s;testRunnerProcess(''%s'', %s,%d);exit"\n',name_i,MATLAB_REMOTE_PATH___,setup_command,foldername,range,iProc-1);
    disp(command);
    fprintf(f,command);
end
fclose(f);
system(sprintf('chmod 700 %s',script_name));
% fork processes 1...processes
system(script_name);
fprintf(1,'Started %d processes',processes);


