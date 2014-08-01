function PullLSFromIPIDataForPlot(folder)

dir_list = dir(infolder);
for i = 1:numel(dir_list)
    [~,root,ext] = fileparts(dir_list(i).name);
    fileparts = strsplit(root,'_');
    if strcmp(ext,'.mat') && strcmp(fileparts(end),'LS')
        file_path = strcat(folder, root, ext);
        load(file_path,'-mat');

        alpha = 0.01;
        FmaxP = zeros(numel(IPI_results),1); %freq of maximum peak
        FSignP = cell(numel(IPI_results),1); %freq of all peaks significant at alpha
        AlphaSignP = FSignP;                 %alpha of all peaks significant at alpha
        FmaxPFocal = zeros(numel(IPI_results),1);   %freq of max peak for focal region
        FSignPFocal = cell(numel(IPI_results),1);   %freq of all peaks sign at alpha for focal region
        AlphaSignPFocal = FSignPFocal;              %alpha of all peaks sign at alpha for focal region
        for j = 1:numel(IPI_results)
            FmaxP(j) = IPI_results{j}.F(IPI_results{j}.Alpha == min(IPI_results{j}.Alpha));
            FSignP{j} = IPI_results{j}.F(IPI_results{j}.Alpha < alpha);
            AlphaSignP{j} = IPI_results{j}.Alpha(IPI_results{j}.Alpha < alpha);
            idx = IPI_results{j}.F >= 0.0056 & IPI_results{j}.F <= 0.05;
            if sum(idx) > 0
                FocalIPI.F = IPI_results{j}.F(idx);
                FocalIPI.Alpha = IPI_results{j}.Alpha(idx);
                FmaxPFocal(j) = FocalIPI.F(FocalIPI.Alpha == min(FocalIPI.Alpha));
                if min(FocalIPI.Alpha) < alpha
                    FSignPFocal{j} = FocalIPI.F(FocalIPI.Alpha < alpha);
                    AlphaSignPFocal{j} = FocalIPI.Alpha(FocalIPI.Alpha < alpha);
                end
            else
                FmaxPFocal(j) = NaN;
                
            end
        end
        
        figure(1)
        scatter(cell2mat(FSignP),cell2mat(AlphaSignP),'.k')
        set(gca,'YDir','reverse','YScale','log','XScale','log');
        result_path = strcat(folder, fileparts(1),'fig');
        my_save(result_path,figure(1));
        figure(2)
        scatter(cell2mat(FSignPFocal),cell2mat(AlphaSignPFocal),'.k')
        set(gca,'YDir','reverse','YScale','log','XScale','log');
        result_path = strcat(folder, fileparts(1),'Focal.fig');
        my_save(result_path,figure(1));
        
        
    end
    
end

    
function my_save(result_path,IPI_results)

save(result_path,'IPI_results','-mat');
