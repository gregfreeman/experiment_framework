function [isSuccess,events]=testRunnerRunCase(foldername,iCase )
% [isSuccess,events]=testRunnerRunCase(foldername,iCase )
%TESTRUNNERRUNCASE runs an specific test case winthin an experiment
% input:
%  input:
%    foldername specifies the folder from which the test results are collected
%    iCase specifies the one-based index for the test case
%  input files:
%   settings000.mat  defines the settings and events
%   settings defines all the parameters for the specific test case
%   events defines a set of activities that are run during a test
%     events include:
%     (required)  [inputData,settings]=events.loadInputData(settings)   
%     (required)  [outputData,results]=events.runExperiment(inputData,settings)  
%     (optional)  results=events.evaluateMetrics(results,inputData,outputData)  
%     (optional)  events.storeOutputData(outputData, inputData, links)
%                       links is an object with an add method
%                       fullpath=links.add(name,ext) 
%                         returns a path to a numbered file 
%                         with a base name and extension in
%                         the experiments results folder.
%
% output:
%   isSuccess: 0 if the test case produced an error while running
%   events:  events from experiment 
% output files:
%   results000.mat - a file storing the individual test results

    isSuccess=0;
    iCaseLow=mod(iCase,10000);
    iCaseHigh=floor(iCase/10000);
    fname=sprintf('%s/%04d/settings_%04d',foldername,iCaseHigh,iCaseLow);
    input=load(fname,'settings','events');
    results=struct();
    links.nlinks=0;
    links.add=@addLink;
    links.iCase=iCase;
    links.foldername=foldername;
    try
        input.settings.case_number=iCase;       
        input.settings.output_folder=foldername;
        
        [inputData,input.settings]=input.events.loadInputData(input.settings);

        tic
        [outputData,results]=input.events.runExperiment(inputData,input.settings);
        t=toc;
        if ~isfield(results,'settings')
            results.settings=input.settings; % add settings if not already included by experiment 
        end
        
        if isfield(input.events,'evaluateMetrics')
			results=input.events.evaluateMetrics(results,inputData,outputData);
        end
        
        results.runtime=t;
        
        if isfield(input.events,'storeOutputData')
			input.events.storeOutputData(outputData, inputData, links)
            if isfield(links,'links')
                results.links=links.links;
            end
        end
        
        isSuccess=1;
       
    catch exception
        results.error=exception;
        results.errorReport=getReport(exception,'extended');
        disp '*********** Error: '
        disp (results.errorReport)
    end
    iCaseLow=mod(iCase,10000);
    iCaseHigh=floor(iCase/10000);
    fname=sprintf('%s/%04d/results_%04d',foldername,iCaseHigh,iCaseLow);
    save(fname,'results');
    events=input.events;
    
    function linkpath=addLink(name,ext)
        idx=links.nlinks+1;
        links.nlinks=idx;
        
        newlink.name=name;
        iCaseLow=mod(iCase,10000);
        iCaseHigh=floor(iCase/10000);
        if exist('ext','var') && ~isempty(ext)
            newlink.file=sprintf('%04d/%s_%04d.%s',iCaseHigh,name,iCaseLow,ext);
        else
            newlink.file=sprintf('%04d/%s_%04d',iCaseHigh,name,iCaseLow);
        end
        newlink.fullfile=fullfile(foldername,newlink.file);
        links.links(idx)=newlink;
        linkpath=newlink.fullfile;        
    end    
end

