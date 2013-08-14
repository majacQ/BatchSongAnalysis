function [Genotypes,PlotData,PlotDataTempNorm] = SortByGenotype(ControlResults,ControlFileNames,Results,FileNames,Phenotypes,varargin)

% SYNTAX
%
%   SortByGenotype(ControlResults,ControlFileNames,Results,FileNames,Phenotypes,varargin)
%
%   e.g.
%   SortByGenotype(ControlResults,ControlFileNames,Results,FileNames,Phenotypes,'IncludeControls','yes','PoolControls','no')
%
%
% PARAMETERS (all optional)
%
% IncludeControls: 'yes' includes controls. Default = 'yes'
%
% PoolControls: 'yes' all control data is pooled. Default = 'no'
%
% PlotDataTempNorm: Data normalized by temperature. Regression estimated
% from all data
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
defaultPoolControls = 'no';


%add required and optional inputs to parser

addOptional(p,'IncludeControls',defaultIncludeControls);
addOptional(p,'PoolControls',defaultPoolControls );

parse(p,varargin{:});

%redistribute parsed variables to original variable names

IncludeControls = p.Results.IncludeControls;
PoolControls = p.Results.PoolControls;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate effect of temperature on each variable

AllResults = cat(1,Results,ControlResults);
NormStats = struct;
for i = 1:numel(Phenotypes)
    X = [AllResults(:,28),AllResults(:,i)];
    X = mat2dataset(X);
    lm = LinearModel.fit(X);
    NormStats.(Phenotypes{i}).intercept = lm.Coefficients{1,1};
    NormStats.(Phenotypes{i}).slope = lm.Coefficients{2,1};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PlotData = struct;
PlotDataTempNorm = PlotData;
for i = 1:numel(Phenotypes)
    column = 0;
    %collect control data
    if strcmpi(IncludeControls,'yes')
        if strcmpi(PoolControls,'yes')
            column = column + 1;
            PlotData.(Phenotypes{i})(:,column) = ControlResults(:,i);
            PlotDataTempNorm.(Phenotypes{i})(:,column) = ... 
                ControlResults(:,i) - (NormStats.(Phenotypes{i}).slope .* ControlResults(:,28)) - NormStats.(Phenotypes{i}).intercept;
        else
            ControlNames=cell(1,0);
            %get unique control names
            for m = 1:numel(ControlFileNames)
                splitControlFile = regexp(ControlFileNames{m},'_','split');
                ControlNames{m} = splitControlFile{4};
            end
            UniqueControlNames = unique(ControlNames);
            %separate each control into a different column
            for n = 1:numel(UniqueControlNames)
                FileHits = strcmp(ControlNames,UniqueControlNames{n});
                column = column + 1;
                PlotData.(Phenotypes{i})(1:numel(ControlResults(FileHits,i)),column) = ControlResults(FileHits,i);
                PlotData.(Phenotypes{i})(numel(ControlResults(FileHits,i))+1:end,column) = NaN;
                PlotDataTempNorm.(Phenotypes{i})(1:numel(ControlResults(FileHits,i)),column) = ... 
                    ControlResults(FileHits,i) - (NormStats.(Phenotypes{i}).slope .* ControlResults(FileHits,28)) - NormStats.(Phenotypes{i}).intercept; 
                PlotDataTempNorm.(Phenotypes{i})(numel(ControlResults(FileHits,i))+1:end,column) = NaN;
            end
        end
    end
    
    
    %collect experimental data
    Names=cell(1,0);
    %get unique  names
    for m = 1:numel(FileNames)
        splitFile = regexp(FileNames{m},'_','split');
        Names{m} = [splitFile{4} '_' splitFile{5}];
    end
    UniqueNames = unique(Names);
    %separate each genotype into a different column
    for n = 1:numel(UniqueNames)
        FileHits = strcmp(Names,UniqueNames{n});
        column = column + 1;
        PlotData.(Phenotypes{i})(1:numel(Results(FileHits,i)),column) = Results(FileHits,i);
        PlotData.(Phenotypes{i})(numel(Results(FileHits,i))+1:end,column) = NaN;
        PlotDataTempNorm.(Phenotypes{i})(1:numel(Results(FileHits,i)),column) = ... 
                    Results(FileHits,i) - (NormStats.(Phenotypes{i}).slope .* Results(FileHits,28)) - NormStats.(Phenotypes{i}).intercept; 
        PlotDataTempNorm.(Phenotypes{i})(numel(Results(FileHits,i))+1:end,column) = NaN;
    end
end



if strcmpi(PoolControls,'yes')
    Genotypes = cat(2,'Controls',UniqueNames);
else
    Genotypes = cat(2,UniqueControlNames,UniqueNames);
end

