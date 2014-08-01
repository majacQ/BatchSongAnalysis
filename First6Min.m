function First6Min(infolder,outfolder)

dir_list = dir(infolder);
for i = 1:numel(dir_list)
    [~,root,ext] = fileparts(dir_list(i).name);
    filestrings = strsplit(root,'_');
    if strcmp(ext,'.mat') && ~strcmp(filestrings(end),'LS')
        file_path = strcat(infolder, root, ext);
        load(file_path,'-mat');
                
        for j = 1:numel(IPI_results)
            %take first 6 min of ipis
            sixMin = (1e4 * 60 * 6); %time in sample units
            startTime = IPI_results(j).IPI.t(1);
            IPI_results(j).IPI.t = IPI_results(j).IPI.t(IPI_results(j).IPI.t < (startTime + sixMin));
            IPI_results(j).IPI.d = IPI_results(j).IPI.d(IPI_results(j).IPI.t< (startTime + sixMin));
            IPI_results(j).numIPI = numel(IPI_results(j).IPI.d);
            %Need to save results here
            result_path = strcat(outfolder, root,'_from1stPulseTrain_1st6min',ext);
            my_save(result_path,IPI_results);
            
        end
    end
end

function my_save(result_path,IPI_results)

save(result_path,'IPI_results','-mat');
