%Batch Fly Song Analysis

function BatchFlySongAnalysis(daq_file,genotypes,recording_channels,control_genotypes)

% USAGE
%
%
% daq_file: full path and name of daq file (time stamp) that was previously 
% segmented with FlySongSegmenterDAQ (e.g. "20110510132426.daq"). If no path 
% defined, then file assumed to reside in current folder
%
% genotypes: cell array of genotype names (e.g. {'strain1' 'wild_type'})
%
% recording_channels: cell array containing numeric arrays that indicate
% how to group genotypes (e.g. {[1 10] [11 18]})
%
% control_genotype: genotype name of control genotype. Must be one or more 
% of the names specified in "genotypes". If multiple, enter cell array
% *e.g. {'wild_type' 'other_wild_type'}
%

[poolavail,isOpen] = check_open_pool;

num_genotypes = numel(genotypes);

%check to confirm # genotypes == number recording_channels
if num_genotypes ~= numel(recording_channels)
    error('myApp:argChk','Analysis stopped.\nThe number of genotypes must equal the number of recording channels.');
end

%check if _out file exists
[path2daq,daq_root,~] = fileparts(daq_file);
folder = [path2daq '/' daq_root '_out/'];
if ~isdir(folder)
    error('myApp:argChk','Analysis stopped.\nFolder with segmented song does not exist.');
end

%check if control_genotype is one of genotypes
if sum(ismember(genotypes,control_genotypes)) == 0
    error('myApp:argChk','Analysis stopped.\nControl genotype does not match possible genotypes.');
end

%establish Results folder 
timestamp = datestr(now,'yyyymmddHHMMSS');
results_folder = [daq_root '_Results_'  timestamp];
mkdir([path2daq '/' results_folder]);

%get _out folder info
dir_list = dir(folder);
file_num = numel(dir_list);

%make full list of all recording channels and genotypes
all_recording_channels = [];
all_genotypes = {};
for i = 1:num_genotypes
    start = recording_channels{i}(1);
    finish = recording_channels{i}(2);
    all_recording_channels = [all_recording_channels start:finish];
    all_genotypes(start:finish) = cellstr(genotypes{i});
end


parfor y = 1:file_num
%for y = 1:file_num
    
    file = dir_list(y).name; %pull out the file name
    [~,root,ext] = fileparts(file);
    path_file = [folder file];
    if strcmp(ext,'.mat');
        fprintf(['Analyzing file ' root '\n'])
        %find channel number
        %e.g. root = PS_20110315090424_ch12
        channel_pos = strfind(root, '_ch');
        channel = root(channel_pos + 3:end); 
        %find genotype
        genotype = all_genotypes{str2num(channel)};

        %send each analysis job to separate cluster node
        Analysis_Results = AnalyzeChannel(path_file);
        
        if sum(ismember(control_genotypes,genotype)) == 0
            result_path = [path2daq '/' results_folder '/' root '_' genotype '_' timestamp '.mat'];
        else
            result_path = [path2daq '/' results_folder '/' root '_' genotype '_control_' timestamp '.mat'];            
        end
%            save(result_path,'Analysis_Results','-mat');%save all variables in original file
        my_save(result_path,Analysis_Results);
    end
end

check_close_pool(poolavail,isOpen);

%send each file in control folder for analysis on separate cluster node

%when all files are analysed, collect analysis results by genotype

%save matrices of analyzed results in folder results_timestamp
%filename = daqroot_chN_genotypeName_timestampofanalysis.m



function my_save(result_path,Analysis_Results)

save(result_path,'Analysis_Results','-mat');
