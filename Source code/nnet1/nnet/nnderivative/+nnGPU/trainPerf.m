function [trainPerf,trainN] = trainPerf(net,data,hints)

% CALL KERNAL
numMasks = 1;
hints.Perfs_and_N = feval(hints.perfsKernel,...
  hints.Perfs_and_N,... % Output
  net,...
  data.X, data.Xi, data.Pc, data.Pd, ...
  data.Ac, ... % Temporary Storage
  data.T, data.EW, data.masks, ...
  int64(data.Q),int64(data.QAligned),int64(data.TS),int64(numMasks));

Perfs_and_N = gather(hints.Perfs_and_N);
trainPerf = sum(Perfs_and_N(1,:));
trainN = sum(Perfs_and_N(4,:));
