function [results,paramset]=loadExperiment(experiment,rootfolder,varargin)

global RESULT_ROOT___

if ~exist('rootfolder' ,'var') || isempty(rootfolder)
    rootfolder=RESULT_ROOT___;
end
if ~exist([rootfolder '/' experiment '/results.mat'],'file')
    testRunnerCollectSave([rootfolder '/' experiment ],varargin{:} )
end
load([rootfolder '/' experiment '/results']);
load([rootfolder '/' experiment '/paramset']);

end

