function [L2WeightsPerf, L2WeightsGrad] = computeWeightRegularization(calcNet,calcMode,calcHints)

% Copyright 2014 The MathWorks, Inc.

lambda = calcHints.perfParam.L2WeightRegularization;
wb = calcMode.getwb(calcNet,calcHints);
for i = 1:numel(calcHints.learnWB.bInd)
    wb(calcHints.learnWB.bInd{i}) = 0;
end
outputSize = calcHints.outputSizes;
L2WeightsPerf = lambda*sum(wb.^2)/outputSize;
L2WeightsGrad = 2*lambda*wb/outputSize;
end