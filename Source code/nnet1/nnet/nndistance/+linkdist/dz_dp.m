function dp = dz_dp(w,p,z,param)
%LINKDIST.DZ_DP Derivative of weighted input with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,R] = size(w);
  dp = zeros(S,R,'like',w);
end
