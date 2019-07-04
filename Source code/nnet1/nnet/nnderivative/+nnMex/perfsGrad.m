function [trainPerf,valPerf,testPerf,gWB,trainN,valN,testN] = perfsGrad(net,data,hints)

TEMP = zeros(1,ceil(hints.tempSizeBG/8)*8);

numMasks = 3;
[gWB,Perfs,PerfN] = nnMex.bg ...
    (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,data.masks,...
    data.Q,data.TS,numMasks,hints,TEMP,hints.batch);

trainPerf = Perfs(1);
valPerf = Perfs(2);
testPerf = Perfs(3);

trainN = PerfN(1);
valN = PerfN(2);
testN = PerfN(3);

TEMP = [];