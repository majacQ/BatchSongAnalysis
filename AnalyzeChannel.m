function Analysis_Results = AnalyzeChannel(filename)


%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load mat file
%%%%%%%%%%%%%%%%%%%%%%%%%%

load(filename,'-mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%

load('./pulse_model_melanogaster.mat');
OldPulseModel = cpm;
pulses = Pulses.ModelCull2;
pulses.x = GetClips(pulses.w0,pulses.w1,Data.d);
sines = Sines.LengthCull;
sines.clips = GetClips(sines.start,sines.stop,Data.d);
pauseThreshold = 0.5e4; %minimum pause between bouts
minIPI = 290;
maxIPI = 510;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preliminary manipulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%calc IPIS
try
ipi = fit_ipi_model(pulses);
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
    Bouts.x = {};
end

%calculate pulse Max FFT
try
    pulseMFFT = findPulseMaxFFT(pulses,Data.fs);
    pulseMFFT.freqAll = pulseMFFT.freqAll(pulseMFFT.freqAll > 0);
    pulseMFFT.timeAll = pulseMFFT.timeAll(pulseMFFT.freqAll > 0);
catch
   pulseMFFT.freq = {};
   pulseMFFT.time = {};
   pulseMFFT.freqAll = [];
   pulseMFFT.timeAll = [];
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
    Sine2PulseTransProb =  NumSine2PulseTransitions - NumPulse2SineTransitions / NumTransitions;
else
    Sine2PulseTransProb = NaN;
end


%mode pulse train length - DONE

try
    ModePulseTrainLength = kernel_mode(PulseTrainLengths,min(PulseTrainLengths):1:max(PulseTrainLengths));
catch
    ModePulseTrainLength = NaN;
end

%mode sine train length - DONE

try
    ModeSineTrainLength = kernel_mode(SineTrainLengths,min(SineTrainLengths):1:max(SineTrainLengths));
catch
    ModeSineTrainLength = NaN;
end

%ratio sine to pulse - DONE

if PulseTotal > 0
    Sine2Pulse = SineTotal ./ PulseTotal;
    Sine2PulseNorm = sqrt(SineTotal .* PulseTotal) ./ recording_duration';
else
    Sine2Pulse = NaN;
    Sine2PulseNorm = NaN;
end

%mode pulse carrier freq - DONE

try
    ModePulseMFFT = kernel_mode(pulseMFFT.freqAll,min(pulseMFFT.freqAll):.1:max(pulseMFFT.freqAll));
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
    ModeIPI = kernel_mode(culled_ipi.d,min(culled_ipi.d):1:max(culled_ipi.d));
catch
    ModeIPI = NaN;
end

%skewness of IPI - DONE

SkewnessIPI = skewness(culled_ipi.d,0);

%mode of LLRfh fits > 0 of pulses to model - to find odd pulse shapes -
%DONE

try
    LLRfh = Pulses.Lik_pulse2.LLR_fh(Pulses.Lik_pulse2.LLR_fh > 0);
    ModeLLRfh = kernel_mode(LLRfh,min(LLRfh ):.1:max(LLRfh));
catch
    ModeLLRfh = NaN;
end

%mode of amplitude of pulses - DONE

try
    PulseAmplitudes = cellfun(@(y) sqrt(mean(y.^2)),pulses.x);
    ModePulseAmplitudes = kernel_mode(PulseAmplitudes,min(PulseAmplitudes):.0001:max(PulseAmplitudes));
catch
    ModePulseAmplitudes = NaN;
end

%mode of amplitude of sine - DONE

try
    SineAmplitudes = cellfun(@(y) sqrt(mean(y.^2)),sines.clips);
    ModeSineAmplitudes = kernel_mode(SineAmplitudes,min(SineAmplitudes):.0001:max(SineAmplitudes));
catch
    ModeSineAmplitudes = NaN;
end

%pulse model - DONE

PulseModels.OldMean = OldPulseModel.fhM;
PulseModels.OldStd = OldPulseModel.fhS;
PulseModels.NewMean = Pulses.pulse_model2.newfhM;
PulseModels.NewStd = Pulses.pulse_model2.newfhS;

%slope of sine carrier freq in 1st 4 trains of sine song / bout
try
    [dFreq,dTime] = SineTrainFFTinBouts(Sines,sineMFFT,Bouts);
    
    %concatenate along second dimension, calc cov and corr
    maxTrainsPerBout = size(dFreq,3);
    freq = dFreq(:,:,1);
    time = dTime(:,:,1);
    if maxTrainsPerBout > 4
        maxTrainsPerBout = 4;
    end
    for i = 2:maxTrainsPerBout
        freq = cat(2,freq,dFreq(:,:,i));
        time = cat(2,time,dTime(:,:,i));
    end
    allCorrs = zeros(size(time,1),1);
    for i = 1:numel(allCorrs)
        a = nancov(time(i,:),freq(i,:));
        allCorrs(i) = a(1,2) / (sqrt(a(1,1) * a(2,2)));
    end
    CorrSineFreqDynamics = kernel_mode(allCorrs,min(allCorrs):.1:max(allCorrs));
catch
    CorrSineFreqDynamics = NaN;
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
        pulseTrains.start(i) = IpiTrains.d{i}(1);
        pulseTrains.stop(i) = IpiTrains.d{i}(end);
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
    CorrPulseFreq = corr(pulseMFFT.timeAll,pulseMFFT.freqAll);
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
Analysis_Results.Sine2PulseTransProb = Sine2PulseTransProb;
Analysis_Results.ModePulseTrainLength = ModePulseTrainLength;
Analysis_Results.ModeSineTrainLength = ModeSineTrainLength;
Analysis_Results.Sine2Pulse = Sine2Pulse;
Analysis_Results.Sine2PulseNorm = Sine2PulseNorm;
Analysis_Results.ModePulseMFFT = ModePulseMFFT;
Analysis_Results.ModeSineMFFT = ModeSineMFFT;
Analysis_Results.ModeIPI = ModeIPI;
Analysis_Results.SkewnessIPI = SkewnessIPI;
Analysis_Results.ModeLLRfh = ModeLLRfh;
Analysis_Results.ModePulseAmplitudes = ModePulseAmplitudes;
Analysis_Results.ModeSineAmplitudes = ModeSineAmplitudes;
Analysis_Results.CorrSineFreqDynamics=CorrSineFreqDynamics;
Analysis_Results.CorrBoutDuration=CorrBoutDuration;
Analysis_Results.CorrPulseTrainDuration=CorrPulseTrainDuration;
Analysis_Results.CorrSineTrainDuration=CorrSineTrainDuration;
Analysis_Results.CorrSineFreq=CorrSineFreq;
Analysis_Results.CorrPulseFreq=CorrPulseFreq;
Analysis_Results.CorrIpi=CorrIpi;

Analysis_Results.PulseModels = PulseModels;

Analysis_Results.timestamp = timestamp;
