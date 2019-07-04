function dw = backstopParallel(dz,w,p,z,param)
%SCALPROD.BACKSTOPPARALLEL Backpropagate weighted input derivatives to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [~,Q,N] = size(dz);
  dw = bsxfun(@times,dz,p);
  dw = reshape(sum(dw,1),1,1,Q,N);
end
