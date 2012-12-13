function PlotAnalysis(folders,genotypes,control_folders,control_genotypes)

% folders = Cell array of folders containing genotypes to plot
% genotypes = Cell array of genotypes to plot
% control_folders = Cell array of folders containing control 
% control_genotypes = Control genotype(s). All control genotypes are
% included in all plots, but statistics are calculated for grand mean of
% controls.
%
% USAGE
% PlotAnalysis({'folder1' 'folder2'},{'one' 'two' 'three'},['folder3' 'folder1'},{'Ore-R' 'Canton-S'})
%

num_genotypes = numel(genotypes);

%get _out folder info
dir_list = dir(folder);
file_num = numel(dir_list);


%make array to hold logicals that indicate positions of files for each
%genotype

geno_file_locations = zeros(num_genotypes,num_channels);
all_files = {dir_list.name};
file_names = cell(1,num_channels);
for i = 3:file_num
    file_names{i-2} = all_files{i};
end

for i = 1:num_genotypes
    e = strfind(file_names,genotypes{i});
    geno_file_locations(i,:) = ~cellfun(@isempty,e);
end

%initialize structure array to hold data

All_Data(num_channels).AR = [];

%Load analysis results for each genotype
for i = 1:numel(genotypes)%for each genotype
    for j = find(geno_file_locations(i,:));%get each file that matches genotype
        
        file = file_names(j); %pull out the file name
        %[~,root,ext] = fileparts(file);
        path_file = strcat(folder,file);
            
        load(char(path_file),'Analysis_Results');
        All_Data(j).AR = Analysis_Results;
           
    end
end

%plot results vs control for each genotype separately
for i = 1:numel(genotypes)%for each genotype
    %make plots for each variable save to folder for this genotype
    for %each variable, grab data from variable, grab control data, make plot, use auto save function of errorbarjitter
    
        
    
    
    
    
    
    
    
    
    
    end
    
    for %each plot in folder, assemble into super plot
    
    
        
        
        
        
        
        
    
    end
        
end


%TO plot models, center models on 0
% [~,idx] = max(OldPulseModel.fhM);
% plot((0-idx+1:numel(OldPulseModel.fhM)-idx),OldPulseModel.fhM);
% [~,newidx] = max(Pulses.pulse_model2.newfhM);
% plot((0-idx+1:numel(Pulses.pulse_model2.newfhM)-idx),Pulses.pulse_model2.newfhM);
