function dw = backstopParallel(dz,w,p,z,param)
%DOTPROD.BACKSTOPPARALLEL Backpropagate weighted input derivatives to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  dz = reshape(dz,S,1,Q,N); % Sx1xQxN
  p = reshape(p,1,R,Q); % 1xRxQ
  dw = bsxfun(@times,dz,p); % SxRxQxN
end