function clips = splitIPIsToClips(IPI_results,minutes,minIPI)

span = 1e4 * 60 * minutes;

clips = struct('IPI',{},'numIPI',{});
clipnum = 1;
for i = 1:numel(IPI_results)
    first = IPI_results(1).IPI.t(1);
    last = IPI_results(1).IPI.t(end);
    
    numsegments = floor((last-first) /span);
    
    for j = 1:numsegments
        clipsamples = (IPI_results(i).IPI.t >= first & IPI_results(i).IPI.t < first + span);
        clips(clipnum).IPI.t = IPI_results(i).IPI.t(clipsamples);
        clips(clipnum).IPI.d = IPI_results(i).IPI.d(clipsamples);
        clips(clipnum).numIPI = numel(clips(clipnum).IPI.d);
        clipnum = clipnum + 1;
        first = first + span;
    end
end
%delete clips with fewer than minIPI
todelete = [];
for k = 1:numel(clips)
    if clips(k).numIPI < minIPI
        todelete = cat(1,todelete,k);
    end
end
clips(todelete) = [];

