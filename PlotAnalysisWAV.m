function PlotAnalysisWAV(folder_of_folders,control_folder)

% USAGE
%
% folder_of_folders: path to folder containing _out folders, each of which
% contains different genotype. All folders except the control folder will
% be analyzed
%
% e.g. folder_of_folders = '/Users/sternd/Documents/Projects/CourtshipSong.AxlineCh2DfScreen/'
%
% control_folder: name of folder within folder_of_folders that contains
% control genotypes
%
% e.g. control_folder = 'ore-r_out'
%

%collect control data


%get _out folder info
control_folder_path = [folder_of_folders control_folder '/'];
control_dir_list = dir(control_folder_path);
folder_num = numel(control_dir_list);
count = 0;
for y = 1:folder_num
    if ~strncmp(control_dir_list(y).name,'.',1)
        file = control_dir_list(y).name; %pull out the file name
        count = count + 1;
        AR = matfile([control_folder_path file]);
        if count == 1
            Results = AR.Analysis_Results;
        else
            Results = [Results AR.Analysis_Results];
        end
    end
end
controls = Results;



    

%get _out folder info
dir_list = dir(folder_of_folders);
folder_num = numel(dir_list);

for y = 1:folder_num
    if ~strncmp(dir_list(y).name,'.',1)
        if numel(dir_list(y).name) > 3
            if ~isempty(strfind(dir_list(y).name,'_out_Results_'))
                
                folder = dir_list(y).name; %pull out the folder name
                path2folder = [folder_of_folders folder '/'];
                
                file_list = dir(path2folder);
                file_num = numel(file_list);
                
                for iii = 1:numel(file_list)
                    file = file_list(iii).name;
                    [~,root,ext] = fileparts(file);
                    if strcmp(ext,'.mat');
                        count = count + 1;
                        AR = matfile([path2folder file]);
                        if count == 1
                            Results = AR.Analysis_Results;
                        else
                            Results = [Results AR.Analysis_Results];
                        end
                    end
                end
                results = Results;
                Results = [];
                %plot results
                plot_saveResults(controls,results,folder,path2folder);

                
            end
        end
    end
end






%make arrays for plotting
function plot_saveResults(controls,results,folder,path2folder)
SampleSize = zeros(1,2);
num_controls = numel(controls);
SampleSize(1) = num_controls;
num_results = numel(results);
SampleSize(2) = num_results;
maxSampleSize = max(SampleSize);
names = fieldnames(results);
clf;
ha = tight_subplot(6,4,[.03 .04],[.05 .05],[.05 .03]);
for j = 1:22
    Results2Plot = NaN(maxSampleSize,2);
    Trait = names{j};

    
    %collect control data
    for m = 1:num_controls
        Results2Plot(m,1) = controls(m).(Trait)(1);
    end
    %collect results
    for n = 1:num_results
        Results2Plot(n,2) = results(n).(Trait)(1);
    end
    
    %determine whether results are sign diff from controls
    h = ttest2(reshape(Results2Plot(:,1:end-1),1,numel(Results2Plot(:,1:end-1)))',Results2Plot(:,end),0.01);
    
    if h == 1
        %change color of results
        color = 'r';
    else
        color = 'k';
    end
    colors = cell(num_controls + 1,1);
    colors(1:end-1) = {'k'};
    colors{end} = color;
    
    
    %plot in new panel
    axes(ha(j))
    title(Trait)
    errorbarjitter(Results2Plot,ha(j),'Colors',{'k' 'k' color},'color_opts',[1 1 1])
    set(gca,'XTick',[],'YTickLabelMode','auto','XColor',get(gca,'Color'))
    
end
%collect and align models
t = cell(num_results,1);
for y = 1:num_results
    t{y} = results(y).PulseModels.NewMean;
end

max_length = max(cellfun(@length,t));
total_length = 2* max_length;
Z = zeros(num_results,total_length);
if num_results >1
    for n=1:num_results
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
text(0,1,['Genotype = ' folder])



%save figure
set(gcf,'OuterPosition',[2000 1000 900 1100])
set(gcf,'PaperPositionMode','auto')
print(gcf,'-depsc',[path2folder folder 'plot.eps'])
saveas(gcf,[path2folder folder 'plot.fig'])




function my_save(result_path,Analysis_Results)

save(result_path,'Analysis_Results','-mat');

