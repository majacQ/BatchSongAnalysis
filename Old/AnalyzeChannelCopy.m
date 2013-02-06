function Analysis_Results = AnalyzeChannelCopy(filename)


%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load mat file
%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('SplitVec')
load(filename,'-mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%

load('./pulse_model_melanogaster.mat');
Pulses.Lik_Pulse2.LLR_fh = culled_pulseInfo2;
Sines.LengthCull = winnowed_sine;
OldPulseModel = cpm;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preliminary manipulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%calc IPIS
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

%calculate pulse Max FFT
try
    pulseMFFT = findPulseMaxFFT(pulses,Data.fs);
%     pulseMFFT.freqAll = pulseMFFT.freqAll(pulseMFFT.freqAll > 0);
%     pulseMFFT.timeAll = pulseMFFT.timeAll(pulseMFFT.freqAll > 0);
catch
   pulseMFFT.freq = [];
   pulseMFFT.time = [];
   pulseMFFT.MaxFFT = [];
%    pulseMFFT.freqAll = [];
%    pulseMFFT.timeAll = [];
end

%%%%%%%%%%%%%
%%%%%%%%%%%%%
%%%%%%%%%%%%%

%calculate sine Max FFT

if numel(sines.start) > 0
    sineMFFT = findSineMaxFFT(sines,Data.fs);
else
    sineMFFT = NaN;
end

%Total recording, sine, pulse, bouts
recording_duration = length(Data.d);
if numel(sines.start) > 0
    SineTrainNum = numel(sines.start);
    SineTrainLengths = (sines.stop - sines.start);
    SineTotal = sum(SineTrainLengths);
else
    SineTrainNum = NaN;
    SineTrainLengths = NaN;
    SineTotal = NaN;
end

if numel(IpiTrains.t) > 0
    PulseTrainNum = numel(IpiTrains.t);
    PulseTrainLengths = cellfun(@(x) x(end)-x(1), IpiTrains.t);
    PulseTotal = sum(PulseTrainLengths);
else
    PulseTrainNum = NaN;
    PulseTrainLengths = NaN;
    PulseTotal = NaN;
end

%Transition probabilities

NumSine2PulseTransitions = sum(Pauses.sinepulse<pauseThreshold);
NumPulse2SineTransitions = sum(Pauses.pulsesine<pauseThreshold);
NumTransitions = NumSine2PulseTransitions + NumPulse2SineTransitions;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%# pulse trains/min - DONE

PulseTrainsPerMin = PulseTrainNum  * 60/(recording_duration / Data.fs);

%# sine trains / min - DONE

SineTrainsPerMin = SineTrainNum * 60 /(recording_duration / Data.fs);

%total % bouts / min - DONE

BoutsPerMin = numel(Bouts.Start) * 60 / (recording_duration / Data.fs);

% Sine/Pulse within bout Transition Probabilities - DONE

if NumTransitions > 0
    %Sine2PulseTransProb = NumSine2PulseTransitions / NumTransitions;
    TransProb = TranProb(Data,sines,pulses);
    NulltoSongTransProb = [TransProb(1,2) TransProb(1,3)];
    SinetoPulseTransProb = [TransProb(2,3) TransProb(3,2)];
else
    NulltoSongTransProb = [NaN NaN];
    SinetoPulseTransProb = [NaN NaN];
end

%mode pulse train length (sec) - DONE

try
    MedianPulseTrainLength = median(PulseTrainLengths) / Data.fs;
catch
    MedianPulseTrainLength = NaN;
end

%mode sine train length (sec) - DONE

try
    MedianSineTrainLength = median(SineTrainLengths)/ Data.fs;
catch
    MedianSineTrainLength = NaN;
end

%ratio sine to pulse - DONE

if PulseTotal > 0
    Sine2Pulse = SineTotal ./ PulseTotal;
    Sine2PulseNorm = [log10(sqrt(SineTotal.* PulseTotal)./(recording_duration-SineTotal-PulseTotal)) log10(Sine2Pulse)];
else
    Sine2Pulse = NaN;
    Sine2PulseNorm = [NaN NaN];
end

%mode pulse carrier freq - DONE

try
    ModePulseMFFT = kernel_mode(pulseMFFT.MaxFFT,min(pulseMFFT.MaxFFT):.1:max(pulseMFFT.MaxFFT));
catch
    ModePulseMFFT = NaN;
end

%mode sine carrier freq - DONE
try
    ModeSineMFFT = kernel_mode(sineMFFT.freqAll,min(sineMFFT.freqAll):.1:max(sineMFFT.freqAll));
catch
    ModeSineMFFT = NaN;
end

%mode IPI - DONE
try
    ModeIPI = kernel_mode(culled_ipi.d,min(culled_ipi.d):1:max(culled_ipi.d))./10;
catch
    ModeIPI = NaN;
end

%skewness of IPI - DONE

SkewnessIPI = skewness(culled_ipi.d,0);

%mode of LLRfh fits > 0 of pulses to model - to find odd pulse shapes -
%DONE

try
    LLRfh = Pulses.Lik_pulse2.LLR_fh(Pulses.Lik_pulse2.LLR_fh > 0);
    MedianLLRfh = median(LLRfh);
catch
    MedianLLRfh = NaN;
end

%mode of amplitude of pulses - DONE

try
    PulseAmplitudes = cellfun(@(y) sqrt(mean(y.^2)),pulses.x);
    MedianPulseAmplitudes = median(PulseAmplitudes);
catch
    MedianPulseAmplitudes = NaN;
end

%mode of amplitude of sine - DONE

try
    SineAmplitudes = cellfun(@(y) sqrt(mean(y.^2)),sines.clips);
    MedianSineAmplitudes = kernel_mode(SineAmplitudes,min(SineAmplitudes):.0001:max(SineAmplitudes));
catch
    MedianSineAmplitudes = NaN;
end

%pulse model - DONE

PulseModels.OldMean = OldPulseModel.fhM;
PulseModels.OldStd = OldPulseModel.fhS;
PulseModels.NewMean = Pulses.pulse_model2.newfhM;
PulseModels.NewStd = Pulses.pulse_model2.newfhS;

%slope of sine carrier freq within bouts
numBouts = numel(Bouts.Start);
if numBouts >0
 
    [time,freq] = SineFFTTrainsToBouts(Bouts,sines,sineMFFT,4);
    corrs = cellfun(@(x,y) corr(x',y),time,freq);
    
    if ~isempty(corrs)
        CorrSineFreqDynamics = kernel_mode(corrs,min(corrs):.1:max(corrs));
    else
        CorrSineFreqDynamics = NaN;
    end

else
    SlopeSineFreqDynamics = NaN;
    CorrSineFreqDynamics = NaN;
    time = NaN;
    freq = NaN;
end

%corr coef of bout duration vs recording time
try
    CorrBoutDuration = corr(Bouts.Start,(Bouts.Stop - Bouts.Start));
catch
    CorrBoutDuration = NaN;
end

%corr coef of pulse train duration vs recording time
try
    pulseTrains.start = zeros(numel(IpiTrains.t),1);
    pulseTrains.stop = pulseTrains.start;
    for i = 1:numel(IpiTrains.t)
        pulseTrains.start(i) = IpiTrains.t{i}(1);
        pulseTrains.stop(i) = IpiTrains.t{i}(end);
    end
    CorrPulseTrainDuration = corr(pulseTrains.start,pulseTrains.stop - pulseTrains.start);
catch
    CorrPulseTrainDuration = NaN;
end


%corr coef of sine train duration vs recording time
try
    CorrSineTrainDuration = corr(Sines.LengthCull.start,Sines.LengthCull.stop-Sines.LengthCull.start);
catch
    CorrSineTrainDuration = NaN;
end

%corr coef of sine carrier freq vs recording time
try
    CorrSineFreq = corr(sineMFFT.timeAll',sineMFFT.freqAll);
catch
    CorrSineFreq = NaN;
end

%corr coef of pulse carrier freq vs recording time
try
    CorrPulseFreq = corr(pulseMFFT.timeAll',pulseMFFT.freqAll');
catch
    CorrPulseFreq = NaN;
end
%corr coef of IPI vs recording time
try
    CorrIpi = corr(culled_ipi.t',culled_ipi.d');
catch
    CorrIpi = NaN;
end

%timestamp

timestamp = datestr(now,'yyyymmddHHMMSS');

%Analysis_Results.ipi = ipi;
%Analysis_Results.culled_ipi = culled_ipi;

Analysis_Results.PulseTrainsPerMin = PulseTrainsPerMin;
Analysis_Results.SineTrainsPerMin = SineTrainsPerMin;
Analysis_Results.BoutsPerMin = BoutsPerMin;
Analysis_Results.NulltoSongTransProb = NulltoSongTransProb;
Analysis_Results.SinetoPulseTransProb = SinetoPulseTransProb;%and pulse2sine
%Analysis_Results.Pulse2SineTransProb = Pulse2SineTransProb;
Analysis_Results.MedianPulseTrainLength = MedianPulseTrainLength;
Analysis_Results.MedianSineTrainLength = MedianSineTrainLength;
Analysis_Results.Sine2Pulse = Sine2Pulse;
Analysis_Results.Sine2PulseNorm = Sine2PulseNorm;
Analysis_Results.ModePulseMFFT = ModePulseMFFT;
Analysis_Results.ModeSineMFFT = ModeSineMFFT;
Analysis_Results.ModeIPI = ModeIPI;
%Analysis_Results.SkewnessIPI = SkewnessIPI;
Analysis_Results.MedianLLRfh = MedianLLRfh;
Analysis_Results.MedianPulseAmplitudes = MedianPulseAmplitudes;
Analysis_Results.MedianSineAmplitudes = MedianSineAmplitudes;
Analysis_Results.CorrSineFreqDynamics=CorrSineFreqDynamics;
Analysis_Results.CorrBoutDuration=CorrBoutDuration;
Analysis_Results.CorrPulseTrainDuration=CorrPulseTrainDuration;
Analysis_Results.CorrSineTrainDuration=CorrSineTrainDuration;
Analysis_Results.CorrSineFreq=CorrSineFreq;
Analysis_Results.CorrPulseFreq=CorrPulseFreq;
Analysis_Results.CorrIpi=CorrIpi;

Analysis_Results.PulseModels = PulseModels;

Analysis_Results.timestamp = timestamp;

Analysis_Results.SineFFTBouts.time = time;
Analysis_Results.SineFFTBouts.freq = freq;
