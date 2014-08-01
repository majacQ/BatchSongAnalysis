function [FmaxP, AlphaMaxP] = GetMaxLSPeaks(lombStats);


FmaxP = NaN(numel(lombStats),1); %freq of maximum peak
AlphaMaxP = FmaxP;

for j = 1:numel(lombStats)
    if ~isnan(lombStats{j}.F)
        FmaxP(j) = lombStats{j}.F(find(lombStats{j}.Alpha == min(lombStats{j}.Alpha),1));
        AlphaMaxP(j) = min(lombStats{j}.Alpha);
    end
end