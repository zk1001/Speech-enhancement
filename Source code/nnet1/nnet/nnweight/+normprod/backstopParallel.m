function dw = backstopParallel(dz,w,p,z,param)
%NORMPROD.BACKSTOPPARALLEL Backpropagate weighted input derivatives to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  sump = sum(abs(p),1);
  normp = bsxfun(@times,p,1 ./ sump);
  normp(~isfinite(normp)) = 0;
  dw = bsxfun(@times,reshape(dz,S,1,Q,N),reshape(normp,1,R,Q));
end
