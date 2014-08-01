function IPI_results = cullByIPINumber(filename,threshold)

load(filename,'-mat');

y=[IPI_results{:}];
IPI_results = y([y.numIPI]>threshold);