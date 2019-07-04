function [gWB,trainPerf,trainN] = grad(net,data,hints)

TEMP = zeros(1,ceil(hints.tempSizeBG/8)*8);

numMasks = 1;
[gWB,trainPerf,trainN] = nnMex2.bg ...
  (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,data.trainMask,...
  data.Q,data.TS,numMasks,hints,TEMP,hints.batch);

TEMP = [];
