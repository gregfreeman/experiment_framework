function [matrix,x,hplot,hlegend,hxlabel,hylabel]=compareExperimentInteractive(results,paramset,dependentVars,metrics,plotOptions,textOptions,varargin)
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


[matrix,x,hplot,hlegend,hxlabel,hylabel]=compareExperiment(results,paramset,dependentVars,metrics,plotOptions,textOptions,varargin)

numCases=numel(results);
numParams=length(paramset);
[fields{1:numParams}]=paramset.field;
[values{1:numParams}]=paramset.values;
expCardinalityDim=zeros(1,numParams);
for iParameter=1:numParams
    expCardinalityDim(iParameter)=length(paramset(iParameter).values);
end
dependentVarIdx=ismember(fields,dependentVars);
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
x=cell2mat(values{dependentVarIdx});
groupDim=expCardinalityDim(setVarIdx);
numGroups=prod(groupDim);
matrix=zeros(numSets,numX);

for iCase=1:numCases
    [subs{1:numParams}]=ind2sub(expCardinalityDim,iCase);
    caseSubscript = cell2mat(subs);       
    groupSubscript =caseSubscript(setVarIdx);
    groupIdx=mysub2ind(groupDim,groupSubscript);
    dependentSubscript =caseSubscript(dependentVarIdx);
    xIdx=dependentSubscript(1); % assume 1 dependent var
    matrix(groupIdx,xIdx)=iCase;    
end

figuredata=struct();
fid=fopen('show_image_svg.js');
str='';
tline = fgets(fid);
while ischar(tline)
    str=[str tline];
    tline = fgets(fid);
end
fclose(fid);
figuredata.include=str;
set(gcf,'UserData',figuredata)


for iAxes=1:length(hplot{1})
    axesdata=struct();           
    axesdata.onmouseover=cell(size(matrix,2),1);
    axesdata.onmouseout=cell(size(matrix,2),1);
    axesdata.onclick=cell(size(matrix,2),1);
    base_path='results/';
    for iX=1:size(matrix,2)
        iCase=matrix(iAxes,iX);
        [path,name]=fileparts(results(iCase).settings.output_folder);
        iCase2=results(iCase).settings.case_number;
        axesdata.onmouseover{iX}='marker_mouseover(evt)';
        axesdata.onmouseout{iX}='marker_mouseout(evt)';
        axesdata.onclick{iX}=sprintf('marker_click(evt,''%s%s/results_%04d.html'')',base_path,name,iCase2);
    end
    for iPlot=1:length(hplot) % one for each metric
        set(hplot{iPlot}(iAxes),'UserData',axesdata)
    end
end

% myplot2svg('plot.svg')
