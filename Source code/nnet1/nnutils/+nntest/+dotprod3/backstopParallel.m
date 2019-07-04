function dw = backstopParallel(dz,w,p,z,param)
%DOTPROD3.BACKSTOPPARALLEL Backpropagate weighted input derivatives to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  dw = param.beta*bsxfun(@times,reshape(dz,S,1,Q,N),reshape(p,1,R,Q));
end
