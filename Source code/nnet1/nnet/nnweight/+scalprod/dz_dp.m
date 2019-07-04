function d = dz_dp(w,p,z,param)
%SCALPROD.DZ_DP Derivative of weighted input with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  R = size(p,1);
  d = w .* eye(R,'like',w);
end
