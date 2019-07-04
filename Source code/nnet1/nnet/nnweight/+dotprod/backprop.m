function dp = backprop(dz,w,p,z,param)
%DOTPROD.BACKPROP Backpropagate weighted input derivative to input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  dz = reshape(dz,S,Q*N);
  dp = w' * dz;
  dp = reshape(dp,R,Q,N);
end
