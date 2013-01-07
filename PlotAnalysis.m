function PlotAnalysis(folders,genotypes,control_folders,control_genotypes)
%Plot results both with and without outliers, save separate files
PlotResults(folders,genotypes,control_folders,control_genotypes,1)
PlotResults(folders,genotypes,control_folders,control_genotypes,0)



function PlotResults(folders,genotypes,control_folders,control_genotypes,remove_outliers)

% folders = Cell array of folders containing genotypes to plot
% genotypes = Cell array of genotypes to plot
% control_folders = Cell array of folders containing control
% control_genotypes = Cell array of control genotype(s). All control
% genotypes are included in all plots, but statistics are calculated for
% grand mean of controls.
% remove_outliers = logical (1/0) to plot with outliers removed or original
<<<<<<< HEAD
% data
%
=======
% data 
% 
>>>>>>> update
% USAGE
% PlotAnalysis({'folder1' 'folder2'},{'one' 'two' 'three'},['folder3' 'folder1'},{'Ore-R' 'Canton-S'})
%

%collect control data

if nargin < 5
    remove_outliers = 1;
end

numControls = numel(control_genotypes);
numGenotypes = numel(genotypes);

controls = struct();
for i  = 1:numControls
    count = 0;
    for ii = 1:numel(control_folders)
        if control_folders{ii}(end) ~= '/'
            control_folders{ii} = [control_folders{ii} '/'];
        end
        dir_list = dir(control_folders{ii});
        for iii = 1:numel(dir_list)
            file = dir_list(iii).name;
            [~,~,ext] = fileparts(file);
            if ~isempty(strfind(file,control_genotypes{i})) && strcmp(ext,'.mat')
                count = count + 1;
                AR = load([control_folders{ii} file], '-mat');
                if count == 1
                    Results = AR.Analysis_Results;
                else
                    Results = [Results AR.Analysis_Results];
                end
            end
        end
    end
    varname = genvarname(control_genotypes{i});
    controls.(varname) = Results;
end

SampleSize = zeros(1,numControls+1);
for x = 1:numControls
    varname = genvarname(control_genotypes{x});
    SampleSize(x) = numel(controls.(varname));
end


%collect target results

results = struct();
for i  = 1:numel(genotypes)
    count = 0;
    for ii = 1:numel(folders)
        if folders{ii}(end) ~= '/'
            folders{ii} = [folders{ii} '/'];
        end
        dir_list = dir(folders{ii});
        for iii = 1:numel(dir_list)
            file = dir_list(iii).name;
            [~,~,ext] = fileparts(file);
            if ~isempty(strfind(file,genotypes{i})) && strcmp(ext,'.mat')
                count = count + 1;
                AR = load([folders{ii} file], '-mat');
                if count == 1
                    Results = AR.Analysis_Results;
                else
                    Results = [Results AR.Analysis_Results];
                end
            end
        end
    end
    varname = genvarname(genotypes{i});
    results.(varname) = Results;
end


%make arrays for plotting
for i = 1:numel(genotypes) %for each genotype
    geno_varname = genvarname(genotypes{i});
    numSamples = numel(results.(geno_varname));
    SampleSize(end) = numSamples;
    maxSampleSize = max(SampleSize);
    names = fieldnames(results.(geno_varname));
    clf;
    ha = tight_subplot(6,4,[.04 .04],[.05 .05],[.05 .03]);
    for j = 1:22
        Results2Plot = NaN(maxSampleSize,numControls+1);
        Trait = names{j};
        
<<<<<<< HEAD
        if ~strcmp(Trait,'Sine2PulseNorm')
            
            %collect control data
            for k = 1:numControls
                control_varname = genvarname(control_genotypes{k});
                for m = 1:numel(controls.(control_varname))
                    Results2Plot(m,k) = controls.(control_varname)(m).(Trait)(1);
                end
            end
            %collect results
            for n = 1:numSamples
                Results2Plot(n,end) = results.(geno_varname)(n).(Trait)(1);
            end
            
            if remove_outliers == 1
                if sum(isnan(Results2Plot(:,1))) ~= numel(Results2Plot(:,1))
                    [OutliersRemovedResults2Plot(:,1),controlidx,~] = deleteoutliers(Results2Plot(:,1),.05,1);
                else
                    OutliersRemovedResults2Plot(:,1) = Results2Plot(:,1);
                    controlidx = [];
                end
                if sum(isnan(Results2Plot(:,2))) ~= numel(Results2Plot(:,2))
                    [OutliersRemovedResults2Plot(:,2),dataidx,~] = deleteoutliers(Results2Plot(:,2),.05,1); 
                else
                    OutliersRemovedResults2Plot(:,2) = Results2Plot(:,2);
                    dataidx = [];
                end
            else
                OutliersRemovedResults2Plot = Results2Plot;
                controlidx= [];
                dataidx = [];
            end
            
            %determine whether results are sign diff from controls
            h = ttest2(reshape(OutliersRemovedResults2Plot(:,1:end-1),1,numel(OutliersRemovedResults2Plot(:,1:end-1)))',OutliersRemovedResults2Plot(:,end),0.01);
            
            if h == 1
                %change color of results
                color = 'r';
            else
                color = 'k';
            end
            colors = cell(numControls + 1,1);
            colors(1:end-1) = {'k'};
            colors{end} = color;
            
            
            %plot in new panel
            axes(ha(j))
            title(Trait)
            errorbarjitter(OutliersRemovedResults2Plot,ha(j),'Ave_Marker','+','Colors',colors,'color_opts',[1 1 1])
            set(gca,'XTick',[],'YTickLabelMode','auto','XColor',get(gca,'Color'))
            if numel(controlidx) > 0
                text(0.15,-.1,['# Outliers=' num2str(numel(controlidx))],'Units','normalized', 'interpreter', 'none')
            end
            if numel(dataidx) > 0
                text(0.5,-.1,['# Outliers=' num2str(numel(dataidx))],'Units','normalized', 'interpreter', 'none')
            end
            
            
        else %plot scatter plots for normalized sine to pulse
            NormS2P2Plot = NaN(maxSampleSize,2*(numControls+1));
            %collect control data
            for k = 1:numControls
                control_varname = genvarname(control_genotypes{k});
                for m = 1:numel(controls.(control_varname))
                    p = (k*2)/2;
                    NormS2P2Plot(m,[p p+numControls+1]) = controls.(control_varname)(m).(Trait)([2 1]);
                end
            end
            %collect results
            for n = 1:numSamples
                NormS2P2Plot(n,[numControls+1 end]) = results.(geno_varname)(n).(Trait)([2 1]);
            end
            
            %determine whether results are sign diff from controls
            %make arrays for aoctool
            A = reshape(NormS2P2Plot,[],2);
            x = A(:,1);
            y = A(:,2);
            group = ones(size(x,1),1);
            group(1:numControls*maxSampleSize) = 0;
            [~,~,h] = aoctool(x,y,group,[],[],[],[],'off');
            
            [Introw,~] = find(strcmp(h,'Intercept') == 1);
            [Sloperow,~] = find(strcmp(h,'Slope') == 1);
            [~,Probcol] = find(strcmp(h,'Prob>|T|') == 1);
            
            
            if h{Introw,Probcol} < 0.01 || h{Sloperow,Probcol} < 0.01
                %change color of results
                color = 'r';
            else
                color = 'k';
            end
            
            %plot in new panel
            axes(ha(j))
            title(Trait)
            hold on
            for k = 1:numControls
                p = (k*2)/2;
                x = NormS2P2Plot(:,p);
                y = NormS2P2Plot(:,p+numControls+1);
                scatter(x,y,'k')
                brob = robustfit(x,y);
                plot(x,brob(1)+brob(2)*x,'k')
            end
            
            x = NormS2P2Plot(:,numControls+1);
            y = NormS2P2Plot(:,end);
            scatter(x,y,color)
            brob = robustfit(x,y);
            plot(x,brob(1)+brob(2)*x,color)
            
            set(gca,'XTick',[],'YTickLabelMode','auto')
            set(get(gca,'Xlabel'),'string','Amt Song')
            set(get(gca,'YLabel'),'string','Sine2Pulse')
            
        end
=======
        if remove_outliers == 1
            [OutliersRemovedResults2Plot(:,1),controlidx,~] = deleteoutliers(Results2Plot(:,1),.05,1);
            [OutliersRemovedResults2Plot(:,2),dataidx,~] = deleteoutliers(Results2Plot(:,2),.05,1);
        else
            OutliersRemovedResults2Plot = Results2Plot;
            controlidx= [];
            dataidx = [];
        end
            
        %determine whether results are sign diff from controls
        h = ttest2(reshape(OutliersRemovedResults2Plot(:,1:end-1),1,numel(OutliersRemovedResults2Plot(:,1:end-1)))',OutliersRemovedResults2Plot(:,end),0.01);
        
        if h == 1
            %change color of results
            color = 'r';
        else
            color = 'k';
        end
        colors = cell(numControls + 1,1);
        colors(1:end-1) = {'k'};
        colors{end} = color;
        
        
        %plot in new panel
        axes(ha(j))
        title(Trait)
        errorbarjitter(OutliersRemovedResults2Plot,ha(j),'Ave_Marker','+','Colors',colors,'color_opts',[1 1 1])
        set(gca,'XTick',[],'YTickLabelMode','auto','XColor',get(gca,'Color'))
        if numel(controlidx) > 0
            text(0.15,-.1,['# Outliers=' num2str(numel(controlidx))],'Units','normalized', 'interpreter', 'none')
        end
        if numel(dataidx) > 0
            text(0.5,-.1,['# Outliers=' num2str(numel(dataidx))],'Units','normalized', 'interpreter', 'none')
        end
        
>>>>>>> update
    end
    %collect and align models
    t = cell(numSamples,1);
    for y = 1:numSamples
        t{y} = results.(geno_varname)(y).PulseModels.NewMean;
    end
    
    max_length = max(cellfun(@length,t));
    total_length = 2* max_length;
    Z = zeros(numSamples,total_length);
    if numSamples >1
        for n=1:numSamples
            if ~isempty(t{n})
                X = t{n};
                T = length(X);
                [~,C] = max(abs(X));%get position of max power
                %flip model is strongest power is negative
                if X(C) <0
                    X = -X;
                end
                %center on max power
                left_pad = max_length - C;  %i.e. ((total_length/2) - C)
                right_pad = total_length - T - left_pad;
                Z(n,:) = [zeros(1,left_pad) X zeros(1,right_pad)];
            end
        end
    end
    %trim down models
    first = find(sum(Z,1),1,'first');
    last = find(sum(Z,1),1,'last');
    Z = Z(:,first:last);
    plot(ha(j+1),Z');
    axis(ha(j+1),'tight');
    axis([ha(j+1) ha(j+2)],'off');
    
    %print useful information in final panel
    axes(ha(j+2))
    text(0,1,['Genotype = ' char(genotypes{1})], 'interpreter', 'none')
    %collect data folders
    resFolders = [];
    for a= 1:numel(folders)
        folder = regexp(folders{a},'/','split');
        resFolders= [resFolders '  ' folder(end-1)];
    end
    text(0,.8,['Analysis Folders = ' resFolders], 'interpreter', 'none')
    
    %collect controls
    conGenos = [];
    for a= 1:numControls
        conGenos = [conGenos '  ' char(control_genotypes{a})];
    end
    text(0,.5,['Controls = ' conGenos], 'interpreter', 'none')
    
    %collect control folders
    conFolders = [];
    for a= 1:numel(folders)
        folder = regexp(control_folders{a},'/','split');
        conFolders= [conFolders '  ' folder(end-1)];
    end
    text(0,.3,['Control Folders = ' conFolders], 'interpreter', 'none')
    
    
    %save figure
    set(gcf,'OuterPosition',[500 1000 900 1150])
    set(gcf,'PaperPositionMode','auto')
    if remove_outliers == 1
        print(gcf,'-depsc',[folders{1} genotypes{i} '_OutliersRemoved.eps'])
        saveas(gcf,[folders{1} genotypes{i} '_OutliersRemoved.fig'])
    else
        print(gcf,'-depsc',[folders{1} genotypes{i} '.eps'])
        saveas(gcf,[folders{1} genotypes{i} '.fig'])
    end
end

