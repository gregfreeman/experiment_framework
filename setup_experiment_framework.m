fullpath = mfilename('fullpath');
idx      = find(fullpath == filesep);
folder = fullpath(1:(idx(end)-1));

addpath([folder '/analysis'])
addpath([folder '/runner'])
addpath([folder '/html'])
addpath([folder '/helpers'])

global DATA_PATH___
global RESULT_ROOT___
global MATLAB_REMOTE_PATH___
global testRunnerFunc
global EXPERIMENT_ROOT___
global EXPERIMENT_FRAMEWORK_ROOT___

if exist('setup_custom.m','file')==2
    disp('Loading setup_custom experiment settings')
    setup_custom
end

if ~exist('EXPERIMENT_ROOT___','var') || isempty(EXPERIMENT_ROOT___)
    EXPERIMENT_ROOT___ = fullfile(folder,'..');
end

if ~exist('EXPERIMENT_FRAMEWORK_ROOT___','var') || isempty(EXPERIMENT_FRAMEWORK_ROOT___)
    EXPERIMENT_FRAMEWORK_ROOT___ = fullfile(folder);
end

if ~exist('DATA_PATH___','var') || isempty(DATA_PATH___)
    DATA_PATH___ = fullfile(EXPERIMENT_ROOT___ ,'..','data');
end

if ~exist('RESULT_ROOT___','var') || isempty(RESULT_ROOT___)
    RESULT_ROOT___=fullfile(EXPERIMENT_ROOT___ , 'results');
end

if ~exist('MATLAB_REMOTE_PATH___','var') || isempty(MATLAB_REMOTE_PATH___)
    MATLAB_REMOTE_PATH___='matlab';
end

if ~exist(RESULT_ROOT___,'dir')
    mkdir(RESULT_ROOT___)
end

if ~exist('testRunnerFunc','var') || isempty(testRunnerFunc)
    testRunnerFunc=@testRunnerSerial;
end