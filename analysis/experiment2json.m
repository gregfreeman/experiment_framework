function experiment2json(experiment,rootfolder,varargin)

global RESULT_ROOT___

if ~exist('rootfolder','var') || isempty(rootfolder)
    rootfolder=RESULT_ROOT___;
end

outputFolder=fullfile(rootfolder,experiment);
 
disp('Loading Experiment')
[results,paramset,info]=loadExperiment(experiment,rootfolder,varargin{:});

disp('Creating results.json')
datafile=fullfile(outputFolder,'results.json');
mat2json(datafile,results(:));
disp('Creating paramset.json')
datafile=fullfile(outputFolder,'paramset.json');
mat2json(datafile,paramset);
disp('Creating info.json')
infofile=fullfile(outputFolder,'info.json');
mat2json(infofile,info);


end

