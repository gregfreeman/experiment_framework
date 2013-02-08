function [exp]=experimentObj(experiment,rootfolder,varargin)
% [exp]=experimentObj(experiment,rootfolder,...)
%experimentObj creates an object managing experiment data
% input:
%   experiment: experiment folder name
%   rootfolder: folder where experiment results are stored
%
%  experimentObj(experiment,rootfolder,...)
%    allows passing options to loadExperiment
% output:
%   exp: experiment structure
%   exp.paramset: experiment parameters
%   exp.results: experiment results
%   exp.info: experiment information
%   exp.series: method to extract series slice from experiment cube
%       d=exp.series(filters,dependentVars,valueField,name)
%         filters:structure representing the values to filter
%         dependentVars:the dependent variable of the series
%         valueField: a result field or function handle to select the
%               results value
%         name: optional value to name the series
%       d.x = dependent values (1xn)
%       d.y = result values (mxn)
%       d.label = labels for series (mx1)
%       d.name = names for series (mx1)
%


    [exp.results,exp.paramset,exp.info]=loadExperiment(experiment,rootfolder,varargin);
 
    exp.series=@series;
    
    function d=series(filters,dependentVars,valueField,name)
        r2=exp.results;
        p2=exp.paramset;
        filt_fields=fieldnames(filters);
        for iField=1:length(filt_fields)
            field=filt_fields{iField};
            if ischar(filters.(field)) && strcmp(filters.(field),'mean')
               [r2,p2]=meanExperimentData(r2,p2,field, {valueField}); 
            else
                if ~iscell(filters.(field))
                    filters.(field)={filters.(field)};
                end
                [r2,p2]=filterExperimentData(r2,p2,field, filters.(field));
            end
        end
        numCases=numel(r2);
        numParams=length(p2);
        [fields{1:numParams}]=p2.field;
        [values{1:numParams}]=p2.values;
        expCardinalityDim=zeros(1,numParams);
        for iParameter=1:numParams
            expCardinalityDim(iParameter)=length(p2(iParameter).values);
        end
        dependentVarIdx=ismember(fields,dependentVars);
        setVarIdx=~dependentVarIdx;
        numDependentVars=sum(dependentVarIdx);
        if numDependentVars>1
            error('only 1 dependent variable is supported')
        end
        
        if ischar(valueField) && ~isfield(r2(1),valueField)
            error(['value field not present in results:' valueField])
        end            
        if ischar(valueField)
            valueSelect=@(x) x.(valueField);
        else
            if ~isa(valueField,'function_handle')
                error('value field must be a function handle or field name')
            end
            valueSelect=valueField;
        end
        setCardinality=setVarIdx.*expCardinalityDim;
        dependentCardinality=dependentVarIdx.*expCardinalityDim;
        numSets=prod(setCardinality(setCardinality>0));
        numX=prod(dependentCardinality(dependentCardinality>0));
        groupDim=expCardinalityDim(setVarIdx);
        numGroups=prod(groupDim);
        d.x=cell2mat(values{dependentVarIdx});
        matrix=zeros(numSets,numX);
        for iCase=1:numCases
            [subs{1:numParams}]=ind2sub(expCardinalityDim,iCase);
            caseSubscript = cell2mat(subs);       
            groupSubscript =caseSubscript(setVarIdx);
            groupIdx=mysub2ind(groupDim,groupSubscript);
            dependentSubscript =caseSubscript(dependentVarIdx);
            xIdx=dependentSubscript(1); % assume 1 dependent var
            y=valueSelect(r2(iCase));
            if ~isempty(y)
                matrix(groupIdx,xIdx)=y;
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
                if isnumeric(valstr) || islogical(valstr)
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

        d.y=matrix;
        d.label=labels;
        if exist('name','var')
            d.name=name;
        else
            d.name=labels;
        end
    end
 
end 
 