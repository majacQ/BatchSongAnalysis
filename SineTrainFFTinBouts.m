function [dFreq,dTime] = SineTrainFFTinBouts(Sines,SineMaxFFT,Bouts)

SineStart = Sines.LengthCull.start;
SineStop = Sines.LengthCull.stop;
SINEFFTtimesall = SineMaxFFT.timeAll;
SINEFFTfreqall = SineMaxFFT.freqAll;
BoutsStart = Bouts.Start;
BoutsStop = Bouts.Stop;

%for plotting, get length of longest sine bout
x = zeros(numel(SineStart,1));
for i = 1:numel(SineStop)
    for j = 1:numel(SineStart)
        z = sum(ismember(SINEFFTtimesall,SineStart(j):SineStop(j)));
        x(i) = z;
    end
end
MaxSineLength= max(x);

%for plotting, get max # of sine bouts per song bout and also total num
%bouts

a = zeros(numel(SineStart),1);
BoutNum = zeros(numel(BoutsStart),1);
NumSineBoutsPerSongBout = cell(numel(BoutsStart),1);
for i = 1:numel(SineStart);
    numBouts = numel(BoutsStart);
    BoutNum(i) = numBouts;
    x = zeros(numBouts,1);
    for j = 1:numBouts
        z = sum(ismember(SineStart,BoutsStart(j):BoutsStop(j)));
        x(j) = z; %Num sine bouts per bout
    end
    NumSineBoutsPerSongBout = x;
    a(i) = max(x);
end
MaxNumSineBouts=max(a);
TotalNumBouts = sum(BoutNum);

%Make 3D array to hold results for plotting
dFreq = NaN(TotalNumBouts,MaxSineLength,MaxNumSineBouts);
dTime = NaN(TotalNumBouts,MaxSineLength,MaxNumSineBouts);

%Dump data from SINEFFTfreq into d

boutNum = 0;
numBouts = numel(BoutsStart);
numSineBouts = NumSineBoutsPerSongBout;
sineBout = 0;
for j = 1:numBouts%for each bout
    boutNum = boutNum + 1;
    for k = 1:numSineBouts(j)%for each bout of sine in a song bout
        sineBout = sineBout+1;
        
        tf = ismember(SINEFFTtimesall,SineStart(sineBout):SineStop(sineBout));
        
        sineLength = sum(tf);
        dTime(boutNum,1:sineLength,k) = SINEFFTtimesall(tf);
        dFreq(boutNum,1:sineLength,k) = SINEFFTfreqall(tf);
        
    end
end

%dim1 = individual trains
%dim2 = individual time points in trains
%dim3 = consecutive trains in a single bout


dFreq(dFreq == 0) = NaN;
dTime(dTime == 0) = NaN;



