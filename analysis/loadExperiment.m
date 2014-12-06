function [results,paramset,info]=loadExperiment(experiment,rootfolder,varargin)

global RESULT_ROOT___

if ~exist('rootfolder' ,'var') || isempty(rootfolder)
    rootfolder=RESULT_ROOT___;
end
if exist(experiment,'dir')
    folder=experiment;
elseif exist(fullfile(rootfolder,experiment),'dir')
    folder=fullfile(rootfolder,experiment);
else
    error('cannot find experiment:%s',experiment);
end
if ~exist(fullfile(folder,'results.mat'),'file')
    testRunnerCollectSave(folder,varargin{:} )
end
load(fullfile(folder,'results'));
load(fullfile(folder,'paramset'));
if ~exist('info','var') % output null info if not included
    info=[];
end
end

