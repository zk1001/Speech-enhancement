function n = summary(calcHints)

% Copyright 2014 The MathWorks, Inc.

n = ['Memory Reduction ' num2str(calcHints.reduction) ' with ' calcHints.subcalc.summary(calcHints.subhints)];
