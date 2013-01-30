function [nCases,foldername]=testRunnerSetup(pathname,paramset,events)
% [nCases,foldername]=testRunnerSetup(pathname,paramset,events)
%TESTRUNNERSETUP setups of an experiment and stores files for each
%experiment instance
% input:
%   pathname defines the base path in which experiment files
%   will reside.  
%   paramset defines an array of structures that define the parameters for
%   the experiment. Each item has a name field that specifies the parameter
%   name.  Each item has a values field that specifies a cell array of
%   different values.
%   events defines a set of functions that are run during the test.
%  
% output:
%   nCases: the total number of cases
%   foldername: the full name of the folder in which experiment files
%   reside.
% output files:
%   settings000.mat - a file for each test case.
%   paramset.mat - a stores a copy of the paramset array.

expDim=ones(1,length(paramset));
for iParameter=1:length(paramset)
    expDim(iParameter)=length(paramset(iParameter).values);
end
nCases=prod(expDim);

[ret, machinename] = system('hostname');
if ret ~= 0,
   if ispc
      machinename = getenv('COMPUTERNAME');
   else
      machinename = getenv('HOSTNAME');
   end
end
machinename = strtrim(lower(machinename));
machinename = strrep(machinename,'-','');
machinename = strrep(machinename,'.','');
foldername=[pathname '_results_' machinename '_' datestr(now,30)];
mkdir(foldername)
mkdir([foldername '/0000'])

subs=cell(length(expDim),1);
for iCase=1:nCases
    settings=struct();
    [subs{1:length(expDim)}]=ind2sub(expDim,iCase);
    caseSubscript = cell2mat(subs);

    for iParameter=1:length(paramset)
        settings.(paramset(iParameter).field)=paramset(iParameter).values{caseSubscript(iParameter)};
    end
    iCaseLow=mod(iCase,10000);
    iCaseHigh=floor(iCase/10000);
    fname=sprintf('%s/%04d/settings_%04d',foldername,iCaseHigh,iCaseLow);
    if mod(iCase,10000)==0
        subfolder=sprintf('%s/%04d',foldername,iCaseHigh);  
        mkdir(subfolder)
    end
    save(fname,'settings','events')

end
info.version='unknown';
info.machinename=machinename;
info.cases=nCases;
info.foldername=foldername;
try
    [~,info.version]=system('git rev-parse HEAD');
catch except
    disp('Cannot get git version information')
   disp(except)
end

save([foldername '/paramset'],'paramset','info')

