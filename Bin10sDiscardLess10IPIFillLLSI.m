function Bin10sDiscardLess10IPIFillLLSI(infolder,outfolder,permute)

%permute (1 = yes, 0 = no)

if nargin < 3
    permute = 0;
end

dir_list = dir(infolder);
for i = 1:numel(dir_list)
    [~,root,ext] = fileparts(dir_list(i).name);
    filestrings = strsplit(root,'_');
    if strcmp(ext,'.mat') && ~strcmp(filestrings(end),'LS')
        file_path = strcat(infolder, root, ext);
        load(file_path,'-mat');
        for j = 1:numel(IPI_results)
            if permute == 1
                m = IPI_results(j).IPI.d;
                IPI_results(j).IPI.d = datasample(m,numel(m),'Replace',false);
            end
            
            IpiTrains = findIpiTrains(IPI_results(j).IPI);
            %bin IPI trains into 10 s intervals based on start time of
            %train
            tenSecondInterval = (1e4 * 10); %time in sample units
            time = IpiTrains.t{1}(1); %start time
            trainStartTimes = cellfun(@(c) c(1),IpiTrains.t);
            numIntervals = floor(trainStartTimes(end) / tenSecondInterval);
            
            for k = 1:numIntervals
                intervalIPIs = [IpiTrains.d{trainStartTimes>=time & trainStartTimes < (time + tenSecondInterval)}];
                
                if numel(intervalIPIs) < 10
                    IPI_results(j).unreduced.d(k) = NaN;
                else
                    IPI_results(j).unreduced.d(k) = nanmean(intervalIPIs);
                end
                IPI_results(j).unreduced.t(k) = nanmean(time + (tenSecondInterval / 2));
                time = time + tenSecondInterval;
            end
            %fill internal NaNs with arithmetic mean
            IPI_results(j).unreduced.d = fillnans(IPI_results(j).unreduced.d);
            %remove flanking NaNs
            IPI_results(j).IPI.d = IPI_results(j).unreduced.d(~isnan(IPI_results(j).unreduced.d));
            IPI_results(j).IPI.t = IPI_results(j).unreduced.t(~isnan(IPI_results(j).unreduced.d));

            
        end
        %Save results here
        result_path = strcat(outfolder, root,'_from1stPulseTrain&10sBins',ext);
        my_save(result_path,IPI_results);
    end
end

function my_save(result_path,IPI_results)

save(result_path,'IPI_results','-mat');
