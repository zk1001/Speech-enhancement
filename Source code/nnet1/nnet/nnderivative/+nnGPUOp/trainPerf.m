function [trainPerf,trainN] = trainPerf(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

[trainPerf,trainN] = nnGPUOp.perfs(net,data,{data.train.mask},hints);
