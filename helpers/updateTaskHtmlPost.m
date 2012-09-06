function updateTaskHtmlPost( folderpath, task_num, done, total)
% updateTaskHtmlPost( folderpath, task_num, done, total)
%  This function posts a task progress via an http post.
%  folderpath  the path of the folder - only the last folder is used in
%     the experiment name
%   task_num - the zero based task (or process) number in an experiment
%   done - the number of experiments that have been completed
%   total - the number of experiments total when finished.


    [~,foldername]=fileparts(folderpath);
    disp '********************************************************'
    progress=100*done/total;
    disp(sprintf('Updating progress task:%d progress:%f',task_num,progress))
    cmd=sprintf('experiment_framework/helpers/update_task_progress.sh %s %d %f',foldername,task_num,progress);
    system(cmd)

end

