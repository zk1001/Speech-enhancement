function data2 = formatData(data1,hints)

% Copyright 2012 The MathWorks, Inc.

data2 = hints.subcalc.formatData(data1,hints.subhints);

if isfield(data1,'T')
  data2.originalT = data1.T;
end

if isfield(data1,'train')
  data2.originalTrainMask = data1.train.mask;
end
