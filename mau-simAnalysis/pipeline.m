
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