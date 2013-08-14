function [GenotypesByDate,PlotData_GenoByDate] = SortByGenotypeAndDate(ControlResults,ControlFileNames,Results,FileNames,Phenotypes,varargin)

%SYNTAX
%
%   SortByGenotypeAndDate(ControlResults,ControlFileNames,Results,FileNames,Phenotypes,varargin)
%
%   e.g.
%   SortByGenotypeAndDate(ControlResults,ControlFileNames,Results,FileNames,Phenotypes,'IncludeControls','yes')
%
%
%   PARAMETERS (all optional)
%
%   IncludeControls: 'yes' includes controls. Default = 'yes'
%   MeanOrMedian: 'Mean' (default) or 'Median)
%
% $	Author: David Stern	$   $   Date :2013/05/10   $
%
% Bug Fixes and Improvements
%



% Check number of inputs
if nargin < 5
    error('CompareGenotypes:notEnoughInputs', 'This function requires at least five inputs.');
end

%establish input argument parser

p = inputParser;

%Set default options

defaultIncludeControls = 'yes';
defaultMeanOrMedian = 'Mean';

%add required and optional inputs to parser

addOptional(p,'IncludeControls',defaultIncludeControls);
addOptional(p,'MeanOrMedian',defaultMeanOrMedian);

parse(p,varargin{:});

%redistribute parsed variables to original variable names

IncludeControls = p.Results.IncludeControls;
MeanOrMedian = p.Results.MeanOrMedian;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get unique set of experimental data names
TimeStampAndGenotype = cell(numel(FileNames),1);
TimeStamps = TimeStampAndGenotype;
for i = 1:numel(FileNames)
    splitFileName = regexp(FileNames{i},'_','split');    
    TimeStampAndGenotype{i} = [splitFileName{2} splitFileName{4} '_' splitFileName{5}];
    TimeStamps{i} = splitFileName{2};
end
UniqueTimeStamps = unique(TimeStamps);
UniqueNames = unique(TimeStampAndGenotype);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PlotData_GenoByDate = struct;

%collect control data for each time stamp
controlResultsByDate = NaN(numel(UniqueTimeStamps),size(ControlResults,2));
for j = 1:numel(UniqueTimeStamps)
    rowsThatMatchTimeStamp = strfind(ControlFileNames,UniqueTimeStamps{j});
    rowsToGrab = ~cellfun(@isempty,rowsThatMatchTimeStamp);
    if strcmpi(MeanOrMedian,'Mean')
        controlResultsByDate(j,:) = nanmean(ControlResults(rowsToGrab,:));
    else
        controlResultsByDate(j,:) = nanmean(ControlResults(rowsToGrab,:));
    end
end

%for each UniqueName
for k = 1:numel(UniqueNames)
    name = UniqueNames{k}(15:end);
    date = UniqueNames{k}(1:14);
    rowsThatMatchName = strfind(FileNames,name);
    rowsThatMatchDate = strfind(FileNames,date);
    DateLogical = ~cellfun(@isempty,rowsThatMatchDate);
    NameLogical = ~cellfun(@isempty,rowsThatMatchName);
    RowsToGrab = NameLogical & DateLogical;
    
    %subtract each result from mean or median of controls
    
    control = controlResultsByDate(strcmp(UniqueTimeStamps,date),:);
    NormResults = Results(RowsToGrab,:) - repmat(control,sum(RowsToGrab),1);
    
    for i = 1:numel(Phenotypes)
        
        PlotData_GenoByDate.(Phenotypes{i})(1:size(NormResults,1),k) = NormResults(:,i);
        PlotData_GenoByDate.(Phenotypes{i})(size(NormResults,1):end,k) = NaN;
        
    end
end

GenotypesByDate = UniqueNames;