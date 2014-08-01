function permuted_ipi = permuteIPI(PulseTimes,minIPI,maxIPI)

%PulseTimes = IPI_results{1}.IPI.t;

p = PulseTimes;
p_shift_one = circshift(p,[0 -1]);
IEI=p_shift_one(1:end-1)-p(1:end-1);

permutedIEI = datasample(IEI,numel(IEI),'Replace',false);

%calc event times from permutedIEI
permutedTimes = zeros(numel(permutedIEI),1);
permutedTimes(1) = 1;
for j = 2:numel(permutedIEI)    %calc up to N-1 time
    permutedTimes(j) = permutedTimes(j-1) + permutedIEI(j-1);
end


%calcIPI
permuted_ipi.d = permutedIEI(permutedIEI > minIPI & permutedIEI < maxIPI);
permuted_ipi.t = permutedTimes(permutedIEI > minIPI & permutedIEI < maxIPI);
