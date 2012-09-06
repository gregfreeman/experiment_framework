function results=testRunnerCollectSave( foldername,varargin )
%TESTRUNNERCOLLECTSAVE collects results of each test case and saves the
%results in a file
%  input:
%    foldername specifies the folder from which the test results are collected
%  output:
%    resultsCollection an n-d array of structures for each test result
%       the dimensions of the array correspond to the paramset definition.
%       each item has a field named 'settings' which include the settings
%       under which the test was run
% output files:
%   results.mat - a file storing all test results.

results=testRunnerCollect( foldername,varargin {:} );
save([foldername '/results'],'results')

