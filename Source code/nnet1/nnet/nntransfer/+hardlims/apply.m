function a = apply(n,param)
%HARDLIMS.APPLY Apply transfer function to inputs

% Copyright 2012-2015 The MathWorks, Inc.


  a = 2.*(n >= 0)-1;
  a(isnan(n)) = nan;
end


