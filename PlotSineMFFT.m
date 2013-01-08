function PlotSineMFFT(Data,Sines,Pulses,ha,bar)

if nargin < 4
    ha = figure(1);
    bar = 1;
else
    axes(ha)
end

if nargin < 4
    bar = 1;
end
    
pauseThreshold = 0.5e4; %minimum pause between bouts
LLR_threshold = 50;
minIPI = 100;
maxIPI = 3000;
try
    pulses.w0 = Pulses.IPICull.w0(Pulses.Lik_pulse2.LLR_fh > LLR_threshold );
    pulses.w1 = Pulses.IPICull.w1(Pulses.Lik_pulse2.LLR_fh > LLR_threshold );
    pulses.wc = pulses.w1 - ((pulses.w1 - pulses.w0)./2);
    pulses.x = GetClips(pulses.w0,pulses.w1,Data.d);
catch
    pulses.x = {};
end
try
    sines = Sines.LengthCull;
    sines.clips = GetClips(sines.start,sines.stop,Data.d)';
catch
    sines.start = [];
    sines.stop = [];
    sines.clips = {};
end
try
    p = pulses.wc;
    p_shift_one = circshift(p,[0 -1]);
    ipi.d=p_shift_one(1:end-1)-p(1:end-1);
    ipi.t = p(1:end-1);
    %ipi = fit_ipi_model(pulses);
    %cull IPIs
    culled_ipi.d = ipi.d(ipi.d > minIPI & ipi.d < maxIPI);
    culled_ipi.t = ipi.t(ipi.d > minIPI & ipi.d < maxIPI);
catch
    ipi.ipi_mean = [];
    ipi.ipi_SD = [];
    ipi.ipi_d = [];
    ipi.ipi_time = [];
    ipi.fit = {};
    culled_ipi.d = [];
    culled_ipi.t = [];
end

if numel(culled_ipi.d) > 1
    %find IPI trains
    IpiTrains = findIpiTrains(culled_ipi);
    %discard IPI trains shorter than max allowed IPI
    IpiTrains.d = IpiTrains.d(cellfun(@(x) ((x(end)-x(1))>maxIPI),IpiTrains.t));
    IpiTrains.t = IpiTrains.t(cellfun(@(x) ((x(end)-x(1))>maxIPI),IpiTrains.t));

    %find All Pauses
    Pauses = findPauses(Data,sines,IpiTrains);
    
    %find Song Bouts
    Bouts = findSongBouts(Data,sines,IpiTrains,Pauses,pauseThreshold);
else
    IpiTrains.d = {};
    IpiTrains.t = IpiTrains.d;
    Pauses.PauseDelta = [];
    Pauses.Type = {};
    Pauses.Time = [];
    Pauses.sinesine = [];
    Pauses.sinepulse = [];
    Pauses.pulsesine = [];
    Pauses.pulsepulse = [];
    Bouts.Start = [];
    Bouts.Stop = [];
%     Bouts.x = {};
end
try
    sines = Sines.LengthCull;
    sines.clips = GetClips(sines.start,sines.stop,Data.d)';
catch
    sines.start = [];
    sines.stop = [];
    sines.clips = {};
end
if numel(sines.start) > 0
    sineMFFT = findSineMaxFFT(sines,Data.fs);
else
    sineMFFT = NaN;
end

[time,freq] = SineFFTTrainsToBouts(Bouts,sines,sineMFFT,4);

maxTrainLength = max(cellfun(@numel,time));
numBouts = numel(time);
D = NaN(numBouts,maxTrainLength);
for i=1:numBouts
    D(i,1:numel(freq{i}')) = freq{i}';
end


%PLOTTING
bins = 50;
xx = linspace(80,200,bins);
D(D<80) = NaN;
D(D>200) = NaN;
Z = hist(D,xx);
M = nanmean(D,1);
S = nanstd(D,1);


%range of times
[~,c] =find(S,1,'last');%plot until only 1 sine train continuing
if c>30 %1.5sec
    c = 30;
end
start = 500;
stop = c * 500;
time_ax = start:500:stop;
if sum(nansum(D))>0
    Z = Z(:,1:c);
    M = M(1:c);
    S = S(1:c);
    pcolor(time_ax,xx,log(Z));
    
    
    colormap cool
    shading flat
    hold on
    %plot mean
    plot(ha,time_ax,M,'k','LineWidth',2)
    plot(ha,time_ax,M+S,'k','LineWidth',1)
    plot(ha,time_ax,M-S,'k','LineWidth',1)
    
    set(ha,'XTick',0:1e4:stop);
    set(ha,'XTickLabel',num2cell(0:5));
    
    if bar == 1
        % plot(time_ax(1),M(1),'oc','MarkerFaceColor','c')
        t = colorbar('peer',gca);
        set(get(t,'ylabel'),'String','Log(N)');
        
        xlabel('Time from start of bout (sec)','fontsize',14);
        ylabel('Sine frequency (Hz)','fontsize',14);
    end
else
    axis off
end