function hints = codeHints(hints)

% Copyright 2012 The MathWorks, Inc.

hints.gWB = gpuArray(zeros(hints.learnWB.wbLen,1));
