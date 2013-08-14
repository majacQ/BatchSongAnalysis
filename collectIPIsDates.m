function [ipi,day,temphyg,timestamp]=collectIPIsDates(folder)
dir_list = dir(folder);
ipi = NaN(numel(dir_list),1);
timestamp = ipi;
day = cell(numel(dir_list),1);
temphyg = NaN(numel(dir_list),2);
j = 0;
for i = 1:numel(dir_list)
    file = dir_list(i).name;
    [~,filename,ext] = fileparts(file);
    if strcmp('.mat',ext)
        j = j+1;
        AR = load([folder file], '-mat');
        ipi(j) = AR.Analysis_Results.ModePeak2PeakIPI;
        filename_parts = regexp(filename,'_','split');
        date = filename_parts(2);
        %format mm/dd/yyyy
        d = date{1};
        timestamp(j) = str2num(d);
        day{j} = [d(5:6) '/' d(7:8) '/' d(1:4)];
        %get hyg info
        th = load([folder d '.hyg'],'-ascii');
        temphyg(j,:) = mean(th(:,2:3));
    end
end

day = day(~cellfun('isempty',day));
ipi = ipi(1:numel(day));
timestamp = timestamp(1:numel(day));
temphyg = temphyg(~any(isnan(temphyg),2),:);