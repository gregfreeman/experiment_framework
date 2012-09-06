function testRunnerRemote(paramset,events,basepath_name,machines,user,remotepath)
% resultsCollection=testRunnerRemote(paramset,events,basepath_name,machines,u
% ser,remotepath)
%TESTRUNNERREMOTE runs an experiment that include one of more test cases
% Test cases are run with multiple processes on multiple machines via ssh.
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
%
%   basepath_name: defines the base path for the folder in which experiment files
%   will be generated.  If basepath_name is empty or not specified, this
%   defaults to the name and location of the mfile calling this one.
%   machines: an array of structures with field:
%            name: the name of the machine 
%            processes: the number processes to run on that machine 
%   user:  the username to connect as.  each machine will use the same user
%   remotepath: the path where the experiment files are stored
%          each machine must have access to ca common file path
%  
% output:
%   the function will spawn the processes and return immediately
% output files:
%   settings000.mat - a file for each test case.
%   paramset.mat - a stores a copy of the paramset array.
%   results000.mat - a file storing an individual test results
%   launch.sh - the script file which launches the processes

if ~isunix
    error('testRunnerRemote only works on unix based operating systems');
end

if ~exist('basepath_name','var')
    basepath_name=[];
end
basepath_name=testRunnerFolder(basepath_name);
disp '********************************************************'
disp 'Setting up experiments'
[nCases,foldername]=testRunnerSetup(basepath_name,paramset,events);

idx=find(basepath_name == filesep);
name = basepath_name(idx(end)+1:end);

processes=0;
for iMachine=1:length(machines)
    processes=processes+machines(iMachine).processes;
end

for iMachine=1:length(machines)
    machine=machines(iMachine).name;
    for iProc=1:machines(iMachine).processes
        range=sprintf('%d:%d:%d',iProc,processes,nCases);
        name_i=[name '_proc' num2str(iProc)];
        cmd=sprintf('ssh %s@%s "screen -L -d -t %s -m %s -nodisplay -r \\"cd %s;setup;testRunnerProcess(''%s'', %s);exit\\" "\n',user,machine,name_i,MATLAB_REMOTE_PATH___,remotepath,foldername,range);
        system(cmd)
    end
end
% fork processes 1...processes
system(script_name)

% run process 1
% testRunnerProcess(foldername,1:processes:nCases);

