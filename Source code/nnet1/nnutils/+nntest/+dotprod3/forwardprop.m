function dz = forwardprop(dp,w,p,z,param)
%DOTPROD3.FORWARDPROP Forward propagate derivatives from inputs to outputs

% Copyright 2012-2015 The MathWorks, Inc.

  [R,Q,N] = size(dp);
  S = size(z,1);
  dp = reshape(dp,R,Q*N);
  dz = param.beta*w*dp;
  dz = reshape(dz,S,Q,N);
end