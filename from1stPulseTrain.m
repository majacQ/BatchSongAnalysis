function from1stPulseTrain(infolder,outfolder)

dir_list = dir(infolder);
for i = 1:numel(dir_list)
    [~,root,ext] = fileparts(dir_list(i).name);
    filestrings = strsplit(root,'_');
    if strcmp(ext,'.mat') && ~strcmp(filestrings(end),'LS')
        file_path = strcat(infolder, root, ext);
        load(file_path,'-mat');
        
        
        %This trims events prior to the first pulse train (10 IPIS)
        
        for j = 1:numel(IPI_results)
            IpiTrains = findIpiTrains(IPI_results(j).IPI);
            NumIpiPerTrain = cellfun(@numel,IpiTrains.d);
            FirstIpiTrain = find(NumIpiPerTrain>=10,1);
            TrimmedIPIs.d = [IpiTrains.d{FirstIpiTrain:end}];
            TrimmedIPIs.t = [IpiTrains.t{FirstIpiTrain:end}];
            IPI_results(j).IPI.d =TrimmedIPIs.d;
            IPI_results(j).IPI.t =TrimmedIPIs.t;
        end
        
        %Save results here
        result_path = strcat(outfolder, root,'_from1stPulseTrain',ext);
        my_save(result_path,IPI_results);
        
    end
end

function my_save(result_path,IPI_results)

save(result_path,'IPI_results','-mat');
