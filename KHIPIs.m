function ipiStats=KHIPIs(filename,LLR_threshold)

% addpath('SplitVec')
% addpath('chronux')
load(filename,'-mat');

if nargin < 2
    LLR_threshold = 50;
end

minIPI=150;
maxIPI=650;

pulses.w0 = Pulses.IPICull.w0(Pulses.Lik_pulse2.LLR_fh > LLR_threshold );
pulses.w1 = Pulses.IPICull.w1(Pulses.Lik_pulse2.LLR_fh > LLR_threshold );
pulses.wc = pulses.w1 - ((pulses.w1 - pulses.w0)./2);
p = pulses.wc;
p_shift_one = circshift(p,[0 -1]);
ipi.d=p_shift_one(1:end-1)-p(1:end-1);
ipi.t = p(1:end-1);
culled_ipi.d = ipi.d(ipi.d > minIPI & ipi.d < maxIPI);
culled_ipi.t = ipi.t(ipi.d > minIPI & ipi.d < maxIPI);


ipiStats.numIPI = numel(culled_ipi.d);
ipiStats.IPI.d = culled_ipi.d;
ipiStats.IPI.t = culled_ipi.t;