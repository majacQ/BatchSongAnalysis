function [colarray, ebjData, ebjAlpha] = LSResultsToEBJ(folder,permute,length)

% permute: true or false
% length: 'full' or '5min'

if nargin < 3
    length = 'full';
end

if nargin < 2
    permute = false;
end

%collect results from _LS.mat, organize in file like this
% A = from 1st pulse
% B = 10s bins
% C = Discard < 10 IPIs
% D = fill empty with mean
% E = fill empty with LLSi
%
% five genotypes
% 1 = CantonS
% 2 = simNJ
% 3 = per0
% 4 = perL
% 5 = perS
%
% A1 A2 A3 A4 A5 B1 B2 B3 etc.
% val .  .
% val .  .
% .
% .
%
% colarray = { 'k' 'b' 'c' 'g' 'r' repeat 5 times}
%
% Use these arrays as input for errorbarjitter
%
%

colarray = { 'k' 'b' 'c' 'g' 'r' };
colarray = repmat(colarray,[1,5]);

%for permuted data
if permute
    subfoldernames = {'From1stPulseTrain' 'permutedFrom1stPulseTrain&10sBins' ...
        'permutedFrom1stPulseTrain&10sBinsDiscard<10IPIs' ...
        'permutedFrom1stPulseTrain&10sBinsDiscard<10IPIsFillNaNwithMean' ...
        'permutedFrom1stPulseTrain&10sBinsDiscard<10IPIsFillNaNwithLLSI'};
else
    subfoldernames = {'from1stPulseTrain' 'from1stPulseTrain&10sBins' ...
        'from1stPulseTrain&10sBinsDiscard<10IPIs' ...
        'from1stPulseTrain&10sBinsDiscard<10IPIsFillNaNwithMean' ...
        'from1stPulseTrain&10sBinsDiscard<10IPIsFillNaNwithLLSI'};
end

ebjData = {};
count = 0;
for j = 1:numel(subfoldernames)
    if strcmp(length,'full')
        dir_list = dir([folder subfoldernames{j} '/']);
    elseif strcmp(length,'5min')
        dir_list = dir([folder subfoldernames{j} '/5min_clips/']);
    end
    for i = 1:numel(dir_list);
        [~,root,ext] = fileparts(dir_list(i).name);
        filestrings = strsplit(root,'_');
        if strcmp(ext,'.mat') && strcmp(filestrings(end),'LS')
            if strcmp(length,'full')
                file_path = strcat(folder, subfoldernames{j}, '/',root, ext);
            elseif strcmp(length,'5min')
                file_path = strcat(folder, subfoldernames{j}, '/5min_clips/',root, ext);
            end
            load(file_path,'-mat');
            
            [FmaxP, AlphaMaxP] = GetMaxLSPeaks(lombStats);
            
            if ~strcmp(filestrings(1),'OreR') %skip sparse OreR data
                count = count + 1;
                ebjData{count} = FmaxP;
                ebjAlpha{count} = AlphaMaxP;
            end
        end
    end
end

%clean up first coumns of ebjData
ebjData = padcat(ebjData{:});
ebjAlpha = padcat(ebjAlpha{:});
