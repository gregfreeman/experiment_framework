function [paramset]=diffExperiment(paramset,paramset2)
%[paramset]=diffExperiment(paramset,paramset2)
%DIFFEXPERIMENT diffs the parameters of two experiments 
%   paramset = paramset - paramset2
% input:
%   paramset:  defines all parameters for an experiment
%      an array of structures with fields:
%        name: specifies a parameter name
%        values: cell array of the values for the parameter
%   paramset2: experiment 2parameter set
%  
% output:
%   paramset:  diff experiment parameter set
%

numParams=length(paramset);
numParams2=length(paramset2);

if numParams2~=numParams
    error 'Number of parameters is different'
end

for iParameter=1:numParams
    if ~strcmp(paramset2(iParameter).field, paramset(iParameter).field)
        error('Error parameter name %d is different ("%s" not "%s%)',iParameter, paramset2(iParameter).field, paramset(iParameter).field);        
    end
end

joinDim=0;
for iParameter=1:numParams
    same=1;
    if numel(paramset2(iParameter).values) ~= numel(paramset(iParameter).values)
        same=0;
    else
        for iValue=1:numel(paramset2(iParameter).values)
            same=same && matches(paramset2(iParameter).values,paramset(iParameter).values);            
        end        
    end
    if ~same
        if joinDim
            error('Different in 2 parameters %d and %d',joinDim, iParameter);
        end
        joinDim=iParameter;
    end
end

paramset(joinDim).values=setdiff(paramset(joinDim).values,paramset2(joinDim).values);

function test=matches(a,b)
test=1;
if all(size(a)~=size(b))
    test=0;
else
    if ischar(a)
        test=ischar(b);
        if test && ~all(strcmp(a,b))
            test=0;
        end
    elseif isnumeric(a)
        test=isnumeric(a) && all(a==b);
    else % assume cell
        for i=1:numel(a)
            test=test&& matches(a{i},b{i});
        end
    end
end