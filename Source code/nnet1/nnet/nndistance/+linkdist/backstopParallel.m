function dw = backstopParallel(dz,w,p,z,param)
%LINKDIST.BACKSTOPPARALLEL Backpropagate weighted input derivatives to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  dw = zeros(S,R,Q,N,'like',dz);
end
