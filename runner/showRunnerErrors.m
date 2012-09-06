function showRunnerErrors( results )
%SHOWRUNNERERRORS Summary of this function goes here
%   Detailed explanation goes here

n=numel(results);
for i=1:n
    if ~isempty(results(i).error)
        disp('***************************************************')
        disp(sprintf('Error in case:%d',i))
        disp('Settings:')
        disp(results(i).settings)
        disp('errorReport:')
        disp(results(i).errorReport)        
    end
end


end

