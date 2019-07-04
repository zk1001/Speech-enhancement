function dz = forwardprop(dp,w,p,z,param)
%DOTPROD.FORWARDPROP Propagate derivative from input to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  [R,Q,N] = size(dp);
  S = size(z,1);
  dp = reshape(dp,R,Q*N);
  dz = w * dp;
  dz = reshape(dz,S,Q,N);
end