function a = apply(n,param)
%HARDLIM.APPLY Apply transfer function to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  a = double(n >= 0);
  a(isnan(n)) = nan;
end
