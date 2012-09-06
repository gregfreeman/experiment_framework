function [Ys,Xs,hplot,hlegend,hxlabel,hylabel]=compareExperiment2(results,paramset,dependentVar,xAxisVar,metrics,plotOptions,textOptions,varargin)
% matrix=compareExperiment(results,paramset,dependentVars,metrics,plotOptions
% ,textOptions)
%COMPAREEXPERIMENT compares the results of an experiment
% input:
%   results: defines the test results for an experiment
%     n-d array of structures. The dimensions correspond to paramset
%   paramset:  defines all parameters for an experiment
%      an array of structures with fields:
%        name: specifies a parameter name
%        values: cell array of the values for the parameter
%   dependentVars: the variable name that will be plotted on the dependent
%     axis
%   metrics: the names of the fields that will be plotted on the y axes.
%     can be a cell array containing the name of multiple metrics
%     subplots will be created for each metric
%   plotOptions: optional options for the plot commands
%   textOptions: optional options for plot label commands
%  
% output:
%   matrix: a 3d matrix of the values plotted
%      rows: the dependent axis
%      cols: the series in the plot (all parameters not dependent)
%      3rd dimension: each 
% output plots:
%     subplots will be created for each plotted metric
%     all other parameters will be enumerated as plot series and labeled
%     in the legend
%
% version 2 - allow plotting with an inconsistent dependent variable

if ischar(metrics)
    metrics={metrics};
end

default_labels=1;

if numel(varargin)>0 
    if any(strcmp('no_labels',varargin))
        default_labels=0;
    end
    
end

numCases=numel(results);
numParams=length(paramset);
[fields{1:numParams}]=paramset.field;
[values{1:numParams}]=paramset.values;
expCardinalityDim=zeros(1,numParams);
for iParameter=1:numParams
    expCardinalityDim(iParameter)=length(paramset(iParameter).values);
end
dependentVarIdx=ismember(fields,dependentVar);
setVarIdx=~dependentVarIdx;

numDependentVars=sum(dependentVarIdx);
setCardinality=setVarIdx.*expCardinalityDim;
dependentCardinality=dependentVarIdx.*expCardinalityDim;
numSets=prod(setCardinality(setCardinality>0));
numX=prod(dependentCardinality(dependentCardinality>0));
if numDependentVars >1
    return
end
numMetrics=length(metrics);
groupDim=expCardinalityDim(setVarIdx);
numGroups=prod(groupDim);
Ys=zeros(numSets,numX,numMetrics);
Xs=zeros(numSets,numX);

for iCase=1:numCases
    [subs{1:numParams}]=ind2sub(expCardinalityDim,iCase);
    caseSubscript = cell2mat(subs);       
    groupSubscript =caseSubscript(setVarIdx);
    groupIdx=mysub2ind(groupDim,groupSubscript);
    dependentSubscript =caseSubscript(dependentVarIdx);
    xIdx=dependentSubscript(1); % assume 1 dependent var
    % ys
    for iMetric=1:numMetrics
        if isfield(results(iCase),metrics{iMetric})
            y=results(iCase).(metrics{iMetric});
            if ~isempty(y)
                Ys(groupIdx,xIdx,iMetric)=y;
            end
        else
            warning('Case %d does not have field %s',iCase,metrics{iMetric});
        end
    end
    %xs
    if isfield(results(iCase),xAxisVar)
        x=results(iCase).(xAxisVar);
        if ~isempty(x)
            Xs(groupIdx,xIdx)=x;
        end
    else
        warning('Case %d does not have field %s',iCase,metrics{iMetric});
    end

end
labels=cell(1,numGroups);
group_fields=fields(setVarIdx);
group_values=values(setVarIdx);
numGroupsVars=length(groupDim);
for iGroup=1:numGroups
    str=[];
    [gsubs{1:numGroupsVars}]=ind2sub(groupDim,iGroup);
    groupSubscript = cell2mat(gsubs);  
    for iVar=1:length(groupSubscript)
        fieldstr=group_fields{iVar};
        valstr=group_values{iVar}{groupSubscript(iVar)};
        if isnumeric(valstr)
            valstr=mat2str(valstr);
        elseif iscell(valstr)
            valstr='{cell}';
        end
        if iVar>1
            str=[str ','];
        end
        str=[str sprintf('%s:%s',fieldstr,valstr)];
    end
    labels{iGroup}=str;
end

hplot=cell(numMetrics,1);
for iMetric=1:numMetrics
    subplot(numMetrics,1,iMetric)
    if exist('plotOptions','var') && ~isempty(plotOptions)
        hplot{iMetric}=plot(Xs',Ys(:,:,iMetric)',plotOptions{:});
    else
        hplot{iMetric}=plot(Xs',Ys(:,:,iMetric)');
    end
    if default_labels
        if exist('textOptions','var') && ~isempty(textOptions)
            hlegend(iMetric)=legend(labels,textOptions{:});
            hxlabel(iMetric)=xlabel(xAxisVar,textOptions{:});
            hylabel(iMetric)=ylabel(metrics{iMetric},textOptions{:});
        else
            hlegend(iMetric)=legend(labels);
            hxlabel(iMetric)=xlabel(xAxisVar);
            hylabel(iMetric)=ylabel(metrics{iMetric});
        end
    end
end
