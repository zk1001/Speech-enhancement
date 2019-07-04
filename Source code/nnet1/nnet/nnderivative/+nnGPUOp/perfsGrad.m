function [trainPerf,valPerf,testPerf,gWB,trainN,valN,testN] = perfsGrad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

[gWB,Perfs,PerfN] = nnGPUOp.bg...
  (net,data.Pc,data.Pt,data.Ai,data.T,data.EW,...
  {data.train.mask data.val.mask data.test.mask},data.Q,data.TS,hints);
  
trainPerf = Perfs(1);
valPerf = Perfs(2);
testPerf = Perfs(3);
trainN = PerfN(1);
valN = PerfN(2);
testN = PerfN(3);

