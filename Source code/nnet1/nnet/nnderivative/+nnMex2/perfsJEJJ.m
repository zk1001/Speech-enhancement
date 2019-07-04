function [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = perfsJEJJ(net,data,hints)

TEMP = zeros(1,ceil(hints.tempSizeFJ/8)*8);

numMasks = 3;
[JE,JJ,Perfs,PerfN] = nnMex2.fj ...
   (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,data.masks,...
   data.Q,data.TS,numMasks,hints,TEMP,hints.batch);

trainPerf = Perfs(1);
valPerf = Perfs(2);
testPerf = Perfs(3);
trainN = PerfN(1);
valN = PerfN(2);
testN = PerfN(3);

TEMP = [];