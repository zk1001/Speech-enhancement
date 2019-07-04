function [trainPerf,trainN] = trainPerf(net,data,hints)

TEMP = zeros(1,ceil(hints.tempSizePERFS/8)*8);

numMasks = 1;
[trainPerf,trainN] = nnMex2.perfs ...
  (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,data.trainMask,data.Q,data.TS,numMasks,hints,TEMP,hints.batch);

TEMP = [];