[ControlResults,Results] = CollectResults({'/Volumes/sternlab/behavior/Andy/mau_x_sim/20130219110328_Results_LLR=0_20130219152031'},{'165.1_2.1+'},{'/Volumes/sternlab/behavior/Andy/mau_x_sim/20130219110328_Results_LLR=0_20130219152031'},{'165.1_2.1-'})
x = [ControlResults.ModePeak2PeakIPI]';
numel([ControlResults.ModePeak2PeakIPI]')
x(1:14,2) = [Results.ModePeak2PeakIPI]';
x(x == 0) = NaN;
x(x>80) = NaN;
errorbarjitter(x)

y = [ControlResults.ModeSineMFFT]';
y(1:14,2) = [Results.ModeSineMFFT]';
y(y==0) = NaN'
y(y<140) = NaN;
errorbarjitter(y)