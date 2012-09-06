function foldername=testRunner(paramset,events,basepath_name)
% resultsCollection=testRunner(paramset,events,basepath_name)
%TESTRUNNER runs an experiment that include one of more test cases
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
%  
% output:
%   foldername:  name of the folder in the results folder where results are
%   stored
% output files:
%   settings000.mat - a file for each test case.
%   paramset.mat - a stores a copy of the paramset array.
%   results.mat - a file storing all test results.
%   results000.mat - a file storing an individual test results

global testRunnerFunc
if ~exist('basepath_name','var')
    basepath_name=[];
end
folderpath=testRunnerFunc(paramset,events,basepath_name);
[~,foldername,~]=fileparts(folderpath);
