function BatchKHIPIs(folder,LLR_threshold)

% timestamp = datestr(now,'yyyymmddHHMMSS');
% results_folder = ['RawIPIs=' num2str(LLR_threshold) '_' timestamp];
% mkdir([folder '/' results_folder]);

%get list of files in folder
dir_list = dir(folder);
IPI_results = cell(numel(dir_list),1);
n = 0;
for i = 1:numel(dir_list)
        [~,root,ext] = fileparts(dir_list(i).name);
        if strcmp(ext,'.mat')
            n = n+1;
            fprintf(['Analyzing file ' dir_list(i).name '\n'])
            file_path = strcat(folder, root, ext);
            ipiStats = KHIPIs(file_path,LLR_threshold);
            IPI_results{n}.filename = root;
            IPI_results{n}.numIPI = ipiStats.numIPI;
            IPI_results{n}.IPI.d = ipiStats.IPI.d;
            IPI_results{n}.IPI.t = ipiStats.IPI.t;
        end
end
IPI_results = IPI_results(~cellfun('isempty',IPI_results));
result_path = strcat(folder, 'KHIPIs_LLR=',num2str(LLR_threshold),'.mat');
my_save(result_path,IPI_results);
    
function my_save(result_path,IPI_results)

save(result_path,'IPI_results','-mat');
