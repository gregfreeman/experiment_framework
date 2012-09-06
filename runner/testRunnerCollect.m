function [ resultsCollection ] = testRunnerCollect( foldername,range,postProcess)
%TESTRUNNERCOLLECT collects results of each test case and stores them in an
%    n-d array of structures for each test result
%  input:
%    foldername specifies the folder from which the test results are collected
%  output:
%    resultsCollection an n-d array of structures for each test result
%       the dimensions of the array correspond to the paramset definition.
%       each item has a field named 'settings' which include the settings
%       under which the test was run
%


load([foldername '/paramset'],'paramset')

numParams=length(paramset);
expCardinalityDim=zeros(1,numParams);
for iParameter=1:numParams
    expCardinalityDim(iParameter)=length(paramset(iParameter).values);
end
numCases=prod(expCardinalityDim);

if ~exist('range','var') || isempty(range)
    range=1:numCases;
end
hasPostProcess=0;
if exist('postProcess','var')
    hasPostProcess=1;
end

numResult=numel(range);

resultsCollection=cell(1,numResult);
for iCase=1:numResult
    iCase2=range(iCase);
    try
        iCaseLow=mod(iCase,10000);
        iCaseHigh=floor(iCase/10000);
        fname=sprintf('%s/%04d/results_%04d',foldername,iCaseHigh,iCaseLow);
        load(fname,'results');
%     load(sprintf('%s/settings_%04d',foldername,iCase),'settings');
%     results.settings=settings;
        if hasPostProcess
            results=postProcess(results);
        end
    
    catch exception
        results.error=exception;
        results.errorReport=getReport(exception,'extended');
        disp (sprintf('*********** Error: case %d',iCase2))
        disp (results.errorReport)
    end
    results.caseNum=iCase;
    resultsCollection{iCase}=results;
end

resultsCollection=mycellstruct2mat(resultsCollection);
% resultsCollection=cell2mat(resultsCollection);

resultsCollection=reshape(resultsCollection,expCardinalityDim);
