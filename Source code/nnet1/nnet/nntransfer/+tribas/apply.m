function a = apply(n,param)
%TRIBAS.APPLY Apply transfer function to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  a = max(0,1-abs(n));
  a(isnan(n)) = nan;
end
