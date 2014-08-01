function BatchSplitIPIsToClips(infolder,minutes,minIPI)

fs = 1e4;
%get list of files in folder
dir_list = dir(infolder);
for i = 1:numel(dir_list)
        [~,root,ext] = fileparts(dir_list(i).name);
        filestrings = strsplit(root,'_');
        if strcmp(ext,'.mat') && ~strcmp(filestrings(end),'LS')
            fprintf(['Splitting file ' dir_list(i).name '\n'])
            file_path = strcat(infolder, root, ext);
            load(file_path,'-mat');
            clips = splitIPIsToClips(IPI_results,minutes,minIPI);
            result_path = strcat(infolder, root, '_', num2str(minutes), '_minute_clips', ext);
            my_save(result_path,clips);
        end
end
    
function my_save(result_path,IPI_results)

save(result_path,'IPI_results','-mat');
