function PullLSFromIPIDataForPlot(folder)

dir_list = dir(folder);
for i = 1:numel(dir_list)
    [~,root,ext] = fileparts(dir_list(i).name);
    filestrings = strsplit(root,'_');
    if strcmp(ext,'.mat') && strcmp(filestrings(end),'LS')
        file_path = strcat(folder, root, ext);
        load(file_path,'-mat');

        alpha = 0.01;
        FmaxP = zeros(numel(lombStats),1); %freq of maximum peak
        AlphaMaxP = FmaxP;
        FSignP = cell(numel(lombStats),1); %freq of all peaks significant at alpha
        AlphaSignP = FSignP;                 %alpha of all peaks significant at alpha
%         FmaxPFocal = zeros(numel(lombStats),1);   %freq of max peak for focal region
%         AlphaMaxPFocal = FmaxPFocal;
%         FSignPFocal = cell(numel(lombStats),1);   %freq of all peaks sign at alpha for focal region
%         AlphaSignPFocal = FSignPFocal;              %alpha of all peaks sign at alpha for focal region
        for j = 1:numel(lombStats)
            if ~isnan(lombStats{j}.F)
                FmaxP(j) = lombStats{j}.F(find(lombStats{j}.Alpha == min(lombStats{j}.Alpha),1));
                AlphaMaxP(j) = min(lombStats{j}.Alpha);
                FSignP{j} = lombStats{j}.F(lombStats{j}.Alpha < alpha);
                AlphaSignP{j} = lombStats{j}.Alpha(lombStats{j}.Alpha < alpha);        
             end
        end
        
        
        figure(1)
        %fdr correction for multiple tests - conservation 'dep' test
        %[~,~,corrAlphaSignP] = fdr_bh(cell2mat(AlphaSignP),.05,'dep');
        
        scatter(cell2mat(FSignP),cell2mat(AlphaSignP),'.k')
        set(gca,'YDir','reverse','YScale','log','XScale','log');
        save2pdf([folder filestrings{1} '.pdf'],gcf)
        saveas(gcf,[folder filestrings{1} '.fig'])
        clf;
        figure(2)
        
        
%         scatter(1 ./ cell2mat(FSignP),cell2mat(AlphaSignP),'.k')
%         set(gca,'YDir','reverse','YScale','log','XScale','log');
%         save2pdf([folder filestrings{1} 'Period.pdf'],gcf)
%         saveas(gcf,[folder filestrings{1} 'Period.fig'])
%         clf;
%         
%         scatter(cell2mat(FSignPFocal),cell2mat(AlphaSignPFocal),'.k')
%         set(gca,'YDir','reverse','YScale','log','XScale','log');
%         saveas(gcf,[folder filestrings{1} 'Focal.fig'])
%         save2pdf([folder filestrings{1} 'Focal.pdf'],gcf)
%         clf;
%         figure(3)

        %[~,~,AlphaMaxP] = fdr_bh(AlphaMaxP); %fdr correction for multiple tests

        scatter(FmaxP,AlphaMaxP,'.k')
        set(gca,'YDir','reverse','YScale','log','XScale','log');
        saveas(gcf,[folder filestrings{1} 'MaxP.fig'])
        save2pdf([folder filestrings{1} 'MaxP.pdf'],gcf)
        clf;
%         figure(4)
%         
%         scatter(1 ./ FmaxP,AlphaMaxP,'.k')
%         set(gca,'YDir','reverse','YScale','log','XScale','log');
%         saveas(gcf,[folder filestrings{1} 'MaxPPeriod.fig'])
%         save2pdf([folder filestrings{1} 'MaxPPeriod.pdf'],gcf)
%         clf;

%         scatter(FmaxPFocal,AlphaMaxPFocal,'.k')
%         set(gca,'YDir','reverse','YScale','log','XScale','log');
%         saveas(gcf,[folder filestrings{1} 'MaxPLocal.fig'])
%         save2pdf([folder filestrings{1} 'MaxPLocal.pdf'],gcf)
%         clf;
        
    end
    
end
