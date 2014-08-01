function BatchCullByIPINumber(infolder,outfolder,threshold)

% timestamp = datestr(now,'yyyymmddHHMMSS');
% results_folder = ['RawIPIs=' num2str(LLR_threshold) '_' timestamp];
% mkdir([folder '/' results_folder]);

%get list of files in folder
dir_list = dir(infolder);
for i = 1:numel(dir_list)
        [~,root,ext] = fileparts(dir_list(i).name);
        if strcmp(ext,'.mat')
            fprintf(['Analyzing file ' dir_list(i).name '\n'])
            file_path = strcat(infolder, root, ext);
            IPI_results = cullByIPINumber(file_path,threshold);
            result_path = strcat(outfolder, root, ext);
            my_save(result_path,IPI_results);
        end
end
    
function my_save(result_path,IPI_results)

save(result_path,'IPI_results','-mat');
