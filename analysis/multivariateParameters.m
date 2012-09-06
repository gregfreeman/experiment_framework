function [ paramset2 ] = multivariateParameters( paramset )
% [ paramset2 ] = multivariateParameters( paramset )
%MULTIVARIATEPARAMETERS returns only multivariate parameters for an
%experiment description
% It looks at each parameter and only lists the ones with multiple
% values.
% This can be useful for legend enumeration by not describing parameters
% that do not vary.
% 
% input:
%   paramset:  defines all parameters for an experiment
%      an array of structures with fields:
%        name: specifies a parameter name
%        values: cell array of the values for the parameter
  
% output:
%   paramset2: a new paramset that only include multivariate parameters
%
numParams=length(paramset);
[values{1:numParams}]=paramset.values;
expCardinalityDim=zeros(1,numParams);
for iParameter=1:numParams
    expCardinalityDim(iParameter)=length(paramset(iParameter).values);
end

paramset2=paramset(expCardinalityDim>1);


end

