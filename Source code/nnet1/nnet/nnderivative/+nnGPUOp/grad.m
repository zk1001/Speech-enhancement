function [gWB,trainPerf,trainN] = grad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

[gWB,trainPerf,trainN] = nnGPUOp.bg ...
   (net,data.Pc,data.Pt,data.Ai,data.T,data.EW,{data.train.mask},...
   data.Q,data.TS,hints);

