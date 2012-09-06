function testRunnerProcess(foldername, cases, task)
% resultsCollection=testRunner(paramset,events,basepath_name)
%TESTRUNNERPROCESS reruns an experiment that has already been setup
% input:
%  input:
%    foldername specifies the folder from which the test results are collected
%    cases is an array of which case indexes to run
% input files:
%   settings000.mat - a file for the settings for each test case.
%  
% output:
%   resultsCollection: a collection of the results of all the experiments
% output files:
%   results000.mat - a file storing an individual test results

if ~exist(foldername,'dir')
    error('Error: cannot find folder: %s',foldername)
end

nCases=length(cases);
success_cases=0;
if exist('task','var')
    disp '********************************************************'
    disp(sprintf('starting task %d',task))
end

for iCase=1:nCases
    disp '********************************************************'
    disp (sprintf('Test case %d  (%d of %d)   (%.0f%%)',cases(iCase),iCase,nCases,100*iCase/nCases) );
    
    [isSuccess,events]=testRunnerRunCase(foldername,cases(iCase) );
    
    success_cases=success_cases+isSuccess;

    if exist('task','var') && exist('events','var') && isstruct(events) && isfield(events,'updateTask')
        events.updateTask(foldername,task,iCase,nCases);    
    end

end

disp '********************************************************'
disp (sprintf('Completed %d test cases of %d',success_cases,nCases) );
