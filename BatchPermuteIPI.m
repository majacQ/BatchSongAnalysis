function BatchPermuteIPI(infolder,outfolder)
minIPI = 150;
maxIPI = 650;

dir_list = dir(infolder);
for i = 1:numel(dir_list)
    [~,root,ext] = fileparts(dir_list(i).name);
    filestrings = strsplit(root,'_');
    if strcmp(ext,'.mat') && ~strcmp(filestrings(end),'LS')
        file_path = strcat(infolder, root, ext);
        load(file_path,'-mat');
        for j = 1:numel(IPI_results)
            
            PulseTimes = IPI_results(j).IPI.t;
            permuted_ipi = permuteIPI(PulseTimes,minIPI,maxIPI);
            
            if numel(permuted_ipi.d) > 1000
                IPI_results(j).IPI.d = permuted_ipi.d;
                IPI_results(j).IPI.t = permuted_ipi.t;
            else
                IPI_results(j).IPI.d = NaN;
                IPI_results(j).IPI.t = NaN;
                IPI_results(j).numIPI = 0;
            end
            
        end
        % Remove empty cells
        IPI_results = IPI_results([IPI_results.numIPI] > 1000);
        
        
        %Save results here
        result_path = strcat(outfolder, root,'_permuted',ext);
        my_save(result_path,IPI_results);
    end
    
end

function my_save(result_path,IPI_results)

save(result_path,'IPI_results','-mat');
