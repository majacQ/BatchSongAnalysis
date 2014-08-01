function Bin10sRaw(infolder,outfolder)

dir_list = dir(infolder);
for i = 1:numel(dir_list)
    [~,root,ext] = fileparts(dir_list(i).name);
    filestrings = strsplit(root,'_');
    if strcmp(ext,'.mat') && ~strcmp(filestrings(end),'LS')
        file_path = strcat(infolder, root, ext);
        load(file_path,'-mat');
        for j = 1:numel(IPI_results)
            IpiTrains = findIpiTrains(IPI_results(j).IPI);
            %bin IPI trains into 10 s intervals based on start time of
            %train. This is KH convention (1990.Behavior Genetics.p.628)
%             tenSecondInterval = (1e4 * 10); %time in sample units
%             time = IpiTrains.t{1}(1); %start time
%             trainStartTimes = cellfun(@(c) c(1),IpiTrains.t);
%             numIntervals = floor(trainStartTimes(end) / tenSecondInterval);
%             
%             
%             for k = 1:numIntervals
%                 intervalIPIs = [IpiTrains.d{trainStartTimes>=time & trainStartTimes < (time + tenSecondInterval)}];
%                 IPI_results(j).unreduced.d(k) = nanmean(intervalIPIs);
%                 
%                 IPI_results(j).unreduced.t(k) = nanmean(time + (tenSecondInterval / 2));
%                 
%                 %IPI_results(j).unreduced.d(k) = nanmean([IpiTrains.d{trainStartTimes>=time & trainStartTimes < (time + tenSecondInterval)}]);
%                 %IPI_results(j).unreduced.t(k) = nanmean([IpiTrains.t{trainStartTimes>=time & trainStartTimes < (time + tenSecondInterval)}]);
%                 time = time + tenSecondInterval;
%             end
%             
            %average IPIs every 10 s
            %This is just averaging all IPIs in interval, not how KH did
            %it.
            
            tenSecondInterval = (1e4 * 10); %time in sample units
            time = 1;
            ipi = IPI_results(j).IPI;
            numIntervals = floor(ipi.t(end) / tenSecondInterval); %discard trailing values 
            
            for k = 1:numIntervals
                IPI_results(j).unreduced.d(k)=nanmean(ipi.d(ipi.t>=time & ipi.t<(time + tenSecondInterval)));
                IPI_results(j).unreduced.t(k)=nanmean([time time+tenSecondInterval]);
                time = time + tenSecondInterval;
            end
            IPI_results(j).IPI.d = IPI_results(j).unreduced.d(~isnan(IPI_results(j).unreduced.d));
            IPI_results(j).IPI.t = IPI_results(j).unreduced.t(~isnan(IPI_results(j).unreduced.d));
            %Save results here
            result_path = strcat(outfolder, root,'_from1stPulseTrain&10sBins',ext);
            my_save(result_path,IPI_results);
            
        end
    end
end

function my_save(result_path,IPI_results)

save(result_path,'IPI_results','-mat');
