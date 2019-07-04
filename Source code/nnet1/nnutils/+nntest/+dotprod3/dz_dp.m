function d = dz_dp(w,p,z,param)
%DOTPROD2.DZ_DP Derivative of weighted input with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  d = param.beta*w;
end
