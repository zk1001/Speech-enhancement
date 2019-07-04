function dp = backprop(dz,w,p,z,param)
%DOTPROD3.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  dz = reshape(dz,S,Q*N);
  dp = param.beta * w' * dz;
  dp = reshape(dp,R,Q,N);
end
