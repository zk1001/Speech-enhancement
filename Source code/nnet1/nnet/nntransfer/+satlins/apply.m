function a = apply(n,param)
%SATLINS.APPLY Apply transfer function to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  a = max(-1,min(1,n));
  a(isnan(n)) = nan;
end
