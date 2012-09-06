function startTasksHtmlPost( folderpath, ntasks, email )
% startTasksHtmlPost( folderpath, ntasks, email )
%  This function posts the start of an experiment via an http post.
%  folderpath  the path of the folder - only the last folder is used in
%     the experiment name
%   ntasks - the nmber of tasks in an experiment
%   email - a notification email for the completion of an experiment

[~,foldername]=fileparts(folderpath);
cmd=sprintf('experiment_framework/helpers/init_task_progress.sh %s %d %s',foldername,ntasks,email);
system(cmd)


end

