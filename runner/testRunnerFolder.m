function [ basepath_name ] = testRunnerFolder(basepath_name)
%TESTRUNNERFOLDER Summary of this function goes here
%   Detailed explanation goes here
global RESULT_ROOT___

 if ~exist('basepath_name','var') || isempty(basepath_name)
    mystack = dbstack;
    CallerFileNameWithPath = which(mystack(end).file); % assume runner mfile is 2 levels above this
    [basepath,name,ext] = fileparts(CallerFileNameWithPath);
    basepath_name=fullfile(RESULT_ROOT___,name);
end

end

