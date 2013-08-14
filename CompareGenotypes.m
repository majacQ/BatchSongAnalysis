function [ControlResults,ControlFileNames,Results,FileNames,Phenotypes] = CompareGenotypes(folder_of_folders,LLR)

%SYNTAX
%
%   CompareGenotypes(folder_of_folders,LLR)
%
%   e.g.
%   CompareGenotypes('.',50)
%   CompareGenotypes('.',50)
%
%
% $	Author: David Stern	$   $   Date :2013/05/07   $
%
% Bug Fixes and Improvements
%
                


% Check number of inputs
if nargin < 2
    error('CompareGenotypes:notEnoughInputs', 'This function requires at least two inputs.');
end

if folder_of_folders(end) ~= '/'
    folder_of_folders = [folder_of_folders '/'];
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get list of folders in folder


dir_list = dir(folder_of_folders);
isub=[dir_list(:).isdir];
nameFolds = {dir_list(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
OutFolds = strfind(nameFolds,'_out');
nameFolds = nameFolds(cellfun(@isempty,OutFolds));
LLRFolds = strfind(nameFolds,['_Results_LLR=' num2str(LLR)]);
nameFolds = nameFolds(~cellfun(@isempty,LLRFolds));

ControlResults = NaN(0,28);
Results = ControlResults;
Phenotypes = {'PulseTrainsPerMin' 'SineTrainsPerMin' 'BoutsPerMin' ...
    'NullToSine' 'NullToPulse' 'SineToNull' 'PulseToNull' ...
    'SineToPulse' 'PulseToSine' 'MedianPulseTrainLength'...
    'MedianSineTrainLength' 'Sine2Pulse'...
    'ModePulseMFFT' 'ModeSineMFFT' 'MedianLLRfh' 'ModePeak2PeakIPI'...
    'ModeEnd2PeakIPI' 'ModeEnd2StartIPI' 'MedianPulseAmplitudes' 'MedianSineAmplitudes'...
    'CorrSineFreqDynamics' 'CorrBoutDuration' 'CorrPulseTrainDuration'...
    'CorrSineTrainDuration' 'CorrSineFreq' 'CorrPulseFreq' 'CorrIpi'};

ControlResultsNames = cell(1,0);
DataResultsNames = ControlResultsNames;
ControlFileNames = cell(1,0);
FileNames = ControlFileNames;
nControl = 0;
nData = 0;
%collect unique names in folder
for i = 1:numel(nameFolds)
    folder_split =regexp(nameFolds{i},'_','split');
    folder_date = folder_split{1};
    hyg_name = [folder_date '.hyg'];
    th = load([folder_of_folders hyg_name],'ascii');
    temphyg = mean(th(:,2:3));
    
    %get list of mat files in folder
    foldDirList = dir([folder_of_folders nameFolds{i}]);
    nameFiles = {foldDirList(:).name}';
    matFiles = strfind(nameFiles,'.mat');
    nameFiles = nameFiles(~cellfun(@isempty,matFiles));
    controlFileNums = strfind(nameFiles,'_control_');
    controlFiles = nameFiles(~cellfun(@isempty,controlFileNums));
    dataFiles = nameFiles(cellfun(@isempty,controlFileNums));

	%split controlFiles names and check items 4 and 5 for unique items (set)
    ControlNames = cell(numel(controlFiles),1);
    for m = 1:numel(controlFiles)
        splitControlFile = regexp(controlFiles{m},'_','split');
        ControlNames{m} = splitControlFile{4};
    end
    UniqueControlNames = unique(ControlNames);
    
    ControlResultsNames = cat(2,ControlResultsNames,UniqueControlNames');
    
    for j = 1:numel(controlFiles)
        nControl=nControl + 1;
        ControlFileNames{nControl} = controlFiles{j};
        load([folder_of_folders nameFolds{i} filesep controlFiles{j}],'Analysis_Results');
        for z = 1:numel(Phenotypes)
            ControlResults(nControl,z) = Analysis_Results.(Phenotypes{z});
        end
        %add temp to end
        ControlResults(nControl,z+1) = temphyg(1);
    end
    
    %split dataFiles names and check items 4 and 5 for unique items (set)
    Names = cell(numel(dataFiles),1);
    for n = 1:numel(dataFiles)
        
        splitDataFile = regexp(dataFiles{n},'_','split');
        if strcmp(splitDataFile{4},splitDataFile{end-1})
            Names{n} = splitDataFile{4};
        else
            Names{n} = [splitDataFile{4} splitDataFile{5}];
        end
    end
    UniqueNames = unique(Names);
    
    DataResultsNames = cat(2,DataResultsNames,UniqueNames');
    
    for j = 1:numel(dataFiles)
        nData=nData + 1;
        FileNames{nData} = dataFiles{j};
        load([folder_of_folders nameFolds{i} filesep dataFiles{j}],'Analysis_Results');
        for z = 1:numel(Phenotypes)
            Results(nData,z) = Analysis_Results.(Phenotypes{z});
        end
        %add temp to end
        Results(nData,z+1) = temphyg(1);
    end
end
    
    