function n = summary(calcHints)

% Copyright 2014 The MathWorks, Inc.

if nnstring.starts(calcHints.subcalc.name,'GPU')
  if (calcHints.onlyGPUs)
    suffix = '';
  else
    suffix = ' or CPU';
  end
else
  suffix = '';
end
  
  
n = ['Parallel with ' calcHints.subcalc.summary(calcHints.subhints) suffix ' Workers'];

