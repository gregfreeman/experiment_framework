function testRunnerDistributedSubset(foldername,cases,max_processes,setup_command)
% resultsCollection=testRunnerDistributedSubset(foldername,cases,max_processes,setup_command)
%TESTRUNNERDISTRIBUTEDSUBSET re-runs an experiment subset
% Test cases are run with multiple processes.
% This function only works on linux based operating systems
% input:
%   foldername:  folder with experiment already setup
%   cases: vector of case numbers to run.
%   max_processes: defines the max number of processes to start
% 
%  
% output:
%   the function will spawn the processes and return immediately
% output files:
%   results000.mat - a file storing an individual test results
%   launch.sh - the script file which launches the processes

global MATLAB_REMOTE_PATH___

if ~isunix
    error('testRunnerDistributed only works on unix based operating systems');
end


if ~exist('max_processes','var')
     error('max_processes not defined');
end

% setup_command='setup';
% if isfield(events,'setup_command')
%     setup_command=events.setup_command;
% end 

disp(['Foldername: ' foldername])
nCases=numel(cases);
processes=min(nCases,max_processes);

idx=find(foldername == filesep);
name = foldername(idx(end)+1:end);

script_name=[foldername '/launch.sh'];
f=fopen(script_name,'w');
fprintf(f,'#!/bin/bash\n');
for iProc=1:processes
    range=mat2str(cases(iProc:processes:end));
    name_i=[name '_proc' num2str(iProc)];
    command=sprintf('screen -L -d -t %s -m %s -nodisplay -r "%s;testRunnerProcess(''%s'', %s);exit"\n',name_i,MATLAB_REMOTE_PATH___,setup_command,foldername,range);
    disp(command);
    fprintf(f,command);
end
fclose(f);
system(sprintf('chmod 700 %s',script_name));
% fork processes 1...processes
system(script_name);
fprintf(1,'Started %d processes',processes);


