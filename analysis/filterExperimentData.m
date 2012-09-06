function [results2, paramset2]=filterExperimentData(results,paramset,field, select_values)
% [results2, paramset2]=filterExperimentData(results,paramset,field,
% select_values)
%FILTEREXPERIMENT filters the results of an experiment for a set of
% discrete parameter values
% input:
%   results: defines the test results for an experiment
%     n-d array of structures. The dimensions correspond to paramset
%   paramset:  defines all parameters for an experiment
%      an array of structures with fields:
%        name: specifies a parameter name
%        values: cell array of the values for the parameter
%   field: the variable name that will be filtered
%     axis
%   select_values: the values that will be selected. It can be a cell array
%   containing multiple values.
%  
% output:
%   results2: the filtered set of test results
%   paramset2: a new paramset that describes the filtered test results
%


numParams=length(paramset);
[fields{1:numParams}]=paramset.field;
[values{1:numParams}]=paramset.values;
filterIdx=cell(1,numParams);
for iParameter=1:numParams
    filterIdx{iParameter}=1:length(paramset(iParameter).values);
end

fieldIdx=find(strcmpi(field,fields));
if isempty(fieldIdx)
    warning('Unable to find field "%s" in experiment parameters',field);
end
if ischar(select_values)
    valueIdx=find(strcmpi(select_values,values{fieldIdx}));
elseif isnumeric(select_values)
    valueIdx=find(ismember(cell2mat(values{fieldIdx}),select_values));
else  % assume cell
    if ischar(select_values{1})
        valueIdx=find(ismember(values{fieldIdx},select_values));
%     elseif isnumeric(select_values{1}) && numel(select_values{1})==1
%         valueIdx=find(ismember(cell2mat(values{fieldIdx}),cell2mat(select_values)));
    elseif isnumeric(select_values{1}) 
        valueIdx=[];
        for i=1:numel(select_values)            
            for j=1:numel(values{fieldIdx})
                if norm(select_values{i}-values{fieldIdx}{j})<1e-10
                    valueIdx=[valueIdx j];
                    break;
                end
            end
        end
    else
        error('dont know how to handle paramter type')
    end
end
filterIdx{fieldIdx}=valueIdx;
results2=results(filterIdx{:});
paramset2=paramset;
paramset2(fieldIdx).values=paramset(fieldIdx).values(valueIdx);

