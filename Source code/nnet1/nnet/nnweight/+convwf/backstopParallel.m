function dw = backstopParallel(dz,w,p,z,param)
%CONVWF.BACKSTOPPARALLEL Backpropagate weighted input derivatives to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  M = R-S+1;
  mframe = 0:(M-1);
  dw = zeros(M,Q,N,'like',dz);
  for i=1:S
    dw = dw + bsxfun(@times,p(i+mframe,:),dz(i,:,:));
  end
  dw = reshape(dw,M,1,Q,N);
end
