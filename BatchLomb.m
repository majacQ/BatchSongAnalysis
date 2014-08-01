function BatchLomb(infolder,alpha)

% timestamp = datestr(now,'yyyymmddHHMMSS');
% results_folder = ['RawIPIs=' num2str(LLR_threshold) '_' timestamp];
% mkdir([folder '/' results_folder]);
fs = 1e4;
%get list of files in folder
dir_list = dir(infolder);
for i = 1:numel(dir_list)
        [~,root,ext] = fileparts(dir_list(i).name);
        filestrings = strsplit(root,'_');
        if strcmp(ext,'.mat') && ~strcmp(filestrings(end),'LS')
            fprintf(['Analyzing file ' dir_list(i).name '\n'])
            file_path = strcat(infolder, root, ext);
            load(file_path,'-mat');
            lombStats = cell(numel(IPI_results),1);
            for j = 1:numel(IPI_results)
                if IPI_results(j).numIPI >= 100
                    lombStats{j} = calcLomb(IPI_results(j).IPI,fs,alpha);
                else
                    lombStats{j}.F = NaN;
                end
            end
            result_path = strcat(infolder, root, '_LS', ext);
            my_save(result_path,lombStats);
        end
end
    
function my_save(result_path,lombStats)

save(result_path,'lombStats','-mat');
