function [results2, paramset2]=meanExperimentData(results,paramset,field_set,outputs)
% [results2, paramset2]=meanExperimentData(results,paramset,field_set,outputs)
%MEANEXPERIMENT aggregates results by taking a mean across a parameter
% input:
%   results: defines the test results for an experiment
%     n-d array of structures. The dimensions correspond to paramset
%   paramset:  defines all parameters for an experiment
%      an array of structures with fields:
%        name: specifies a parameter name
%        values: cell array of the values for the parameter
%   field_set: a set of fields that will be aggregated. It can be a cell array
%      containing multiple values.
%   outputs: a cell array containing each field to aggregate.
%  
% output:
%   results2: the aggregated set of test results
%   paramset2: a new paramset that describes the aggregated test results
%

numParams=length(paramset);
[fields{1:numParams}]=paramset.field;
expCardinalityDim=zeros(1,numParams);
for iParameter=1:numParams
    expCardinalityDim(iParameter)=length(paramset(iParameter).values);
end

fieldIdx=strcmpi(field_set,fields);
count=prod(expCardinalityDim(fieldIdx));
outputCount=length(outputs);
paramset2=paramset(~fieldIdx);
expCardinalityDim2=expCardinalityDim(~fieldIdx);
numParams2=length(expCardinalityDim2);
numElements2=prod(expCardinalityDim2);
results2(numElements2)=results(1);
if numParams2>1
    results2=reshape(results2,expCardinalityDim2);
end
for iCase2=1:numElements2
    [subs2{1:numParams2}]=ind2sub(expCardinalityDim2,iCase2);
    caseSubscript2 = cell2mat(subs2);       
    caseSubscript1=ones(1,numParams);
    caseSubscript1(~fieldIdx)=caseSubscript2;
    iCase1=mysub2ind(expCardinalityDim,caseSubscript1);
    
    results2(iCase2)=results(iCase1);
    results2(iCase2).settings=rmfield(results(iCase1).settings, field_set);
end

for iCase2=1:numElements2
    for iOutput=1:outputCount
        results2(iCase2).(outputs{iOutput})=0;
    end
end


for iCase1=1:prod(expCardinalityDim)
    [subs{1:numParams}]=ind2sub(expCardinalityDim,iCase1);
    caseSubscript = cell2mat(subs);       
    caseSubscript2=caseSubscript(~fieldIdx);
    iCase2=mysub2ind(expCardinalityDim2,caseSubscript2);   
    
    for iOutput=1:outputCount
        val=results(iCase1).(outputs{iOutput});
        results2(iCase2).(outputs{iOutput})=results2(iCase2).(outputs{iOutput}) + val./count;
    end
end



