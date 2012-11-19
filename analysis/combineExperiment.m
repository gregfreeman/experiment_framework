function [results,paramset]=combineExperiment(results,paramset,results2,paramset2,path1,path2)
%[results,paramset]=combineExperiment(results,paramset,results2,paramset2)
%COMBINEEXPERIMENT combines the results of two experiments if the union
%forms a complete design matrix
% input:
%   results: defines the test results for an experiment
%     n-d array of structures. The dimensions correspond to paramset
%   paramset:  defines all parameters for an experiment
%      an array of structures with fields:
%        name: specifies a parameter name
%        values: cell array of the values for the parameter
%   results2: experiment 2 results
%   paramset2: experiment 2 parameter set
%   path1: base path for experiment 1 links (optional)
%   path2: base path for experiment 2 links (optional)
%   
% output:
%   results: combined experiment results
%   paramset:  combined experiment parameter set
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

if ~joinDim
    error('Experiments are identical, cannot join');        
end

rs={results,results2};
% rebase link file paths
if exist('path1','var') && exist('path2','var') 
    ps={path1,path2};
    for iExp=1:2
        for i=1:numel(rs{iExp})
            if isfield(rs{iExp}(i),'links')
                links=rs{iExp}(i).links;
                for iLink=1:numel(links)
                    links(iLink).file=fullfile(ps{iExp}, links(iLink).file);
                end
                rs{iExp}(i).links=links;
            end
        end
    end
end

sz1=size(rs{1});
sz2=size(rs{2});
d=max(length(sz1),length(sz2));
sz1(length(sz1)+1:d)=1;
sz2(length(sz2)+1:d)=1;

offset=sz1(joinDim);
sz3=sz1;
sz3(joinDim)=sz1(joinDim)+sz2(joinDim);
results3=cell(sz3);

cidx=cell(1,d);
for i=1:numel(rs{1})
    [cidx{1:d}]=ind2sub(sz1,i);
    idx = cell2mat(cidx); 
    j=mysub2ind(sz3,idx);
    results3{j}=rs{1}(i);
end
for i=1:numel(rs{2})
    [cidx{1:d}]=ind2sub(sz2,i);
    idx = cell2mat(cidx); 
    idx2=idx;
    idx2(joinDim)=idx2(joinDim)+offset;
    j=mysub2ind(sz3,idx2);
    results3{j}=rs{2}(i);
end

% results=cat(joinDim,results,results2);
results=mycellstruct2mat(results3);
results=reshape(results,sz3);
paramset(joinDim).values=[paramset(joinDim).values paramset2(joinDim).values];

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
