
Genotype 4.1

[ControlResults,Results]=CollectResults({'/Volumes/sternlab/behavior/Andy/mau_x_sim/20130207095607_Results_LLR=0_20130207205507'},{'4.1F+'},{'/Volumes/sternlab/behavior/Andy/mau_x_sim/20130207095607_Results_LLR=0_20130207205507' '/Volumes/sternlab/behavior/Andy/mau_x_sim/20130207110048_Results_LLR=0_20130207205904'},{'4.1F-'})
x(:,1) = [ControlResults.ModeSineMFFT]'
x(1:numel([Results.ModeSineMFFT]),2) = [Results.ModeSineMFFT]'
x(x==0) = NaN
errorbarjitter(x)
x(x<140) =NaN
clf
errorbarjitter(x)
[h,p]=ttest2(x(:,1),x(:,2))

Genotype 3.2

[ControlResults,Results]=CollectResults({'/Volumes/sternlab/behavior/Andy/mau_x_sim/20130206110610_Results_LLR=0_20130207205144'},{'3.2F+'},{'/Volumes/sternlab/behavior/Andy/mau_x_sim/20130206110610_Results_LLR=0_20130207205144'},{'3.2F-'})
x(:,1) = [ControlResults.ModeSineMFFT]'
clear x
x(:,1) = [ControlResults.ModeSineMFFT]'
x(1:numel([Results.ModeSineMFFT]),2) = [Results.ModeSineMFFT]'
x(x==0) = NaN
errorbarjitter(x)
clf
errorbarjitter(x)
clf;x(x<140) =NaN
errorbarjitter(x)
clf;x(x>210) =NaN
errorbarjitter(x)
[h,p]=ttest2(x(:,1),x(:,2))


Genotype 5.4

[ControlResults,Results]=CollectResults({'/Volumes/sternlab/behavior/Andy/mau_x_sim/20130215103316_Results_LLR=0_20130218212021'},{'5.4w+'},{'/Volumes/sternlab/behavior/Andy/mau_x_sim/20130215103316_Results_LLR=0_20130218212021'},{'5.4w-'});
x(:,1) = [ControlResults.ModePeak2PeakIPI]';
x(1:numel([Results.ModePeak2PeakIPI]),2) = [Results.ModePeak2PeakIPI]'
x(x==0) = NaN;
errorbarjitter(x)
clf;x(x>140) =NaN;
errorbarjitter(x)
[h,p]=ttest2(x(:,1),x(:,2))

Genotype 165.1_2.1

[ControlResults,Results]=CollectResults({'/Volumes/sternlab/behavior/Andy/mau_x_sim/20130219110328_Results_LLR=0_20130219152031'},{'2.1+'},{'/Volumes/sternlab/behavior/Andy/mau_x_sim/20130219110328_Results_LLR=0_20130219152031'},{'2.1-'});
clear x
x(:,1) = [ControlResults.ModePeak2PeakIPI]';
x(1:numel([Results.ModePeak2PeakIPI]),2) = [Results.ModePeak2PeakIPI]'
x(x==0) = NaN;
errorbarjitter(x)
clf;x(x>80) =NaN;
errorbarjitter(x)
[h,p]=ttest2(x(:,1),x(:,2))

clear x
x(:,1) = [ControlResults.ModeEnd2PeakIPI]';
x(1:numel([Results.ModeEnd2PeakIPI]),2) = [Results.ModeEnd2PeakIPI]'
x(x==0) = NaN;
errorbarjitter(x)
clf;x(x>80) =NaN;
errorbarjitter(x)
[h,p]=ttest2(x(:,1),x(:,2))
