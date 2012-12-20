%Batch Fly Song Analysis

function BatchFlySongAnalysisWAV(folder_of_folders,control_folder)

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

%get _out folder info
dir_list = dir(folder_of_folders);
folder_num = numel(dir_list);

for y = 1:folder_num
    if ~strncmp(dir_list(y).name,'.',1)
        if numel(dir_list(y).name) > 3
            if strcmp(dir_list(y).name(end-2:end),'out')
                folder = dir_list(y).name; %pull out the file name
                path2folder = [folder_of_folders folder '/'];
                %establish Results folder
                timestamp = datestr(now,'yyyymmddHHMMSS');
                results_folder = [folder '_Results_'  timestamp];
                mkdir([folder_of_folders results_folder]);
                
                
                file_list = dir(path2folder);
                file_num = numel(file_list);
                parfor i = 1:file_num
                    if ~strncmp(file_list(i).name,'.',1)
                        file = [path2folder file_list(i).name];
                        [~,root,ext] = fileparts(file);
                        
                        if strcmp(ext,'.mat');
                            
                            Analysis_Results = AnalyzeChannel(file);
                            
                            result_path = [folder_of_folders results_folder '/' root '.mat'];
                            %save(result_path,'Analysis_Results','-mat');%save all variables in original file
                            my_save(result_path,Analysis_Results);
                        end
                    end
                end
            end
        end
    end
end


%send each file in control folder for analysis on separate cluster node

%when all files are analysed, collect analysis results by genotype

%save matrices of analyzed results in folder results_timestamp
%filename = daqroot_chN_genotypeName_timestampofanalysis.m



function my_save(result_path,Analysis_Results)

save(result_path,'Analysis_Results','-mat');
