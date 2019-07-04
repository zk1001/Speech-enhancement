function dw = backstopParallel(dz,w,p,z,param)
%NEGDIST.BACKSTOPPARALLEL Backpropagate weighted input derivatives to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  p = reshape(p,1,R,Q); % 1xRxQ
  z = reshape(z,S,1,Q); % Sx1xQ
  dz = reshape(dz,S,1,Q,N); % Sx1xQxN
  d = bsxfun(@rdivide,bsxfun(@minus,w,p),z); % SxRxQ
  d(~isfinite(d)) = 0;
  dw = bsxfun(@times,d,dz); % SxRxQxN
end
