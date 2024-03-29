function dw = backstopParallel(dz,w,p,z,param)
%DOTPROD2.BACKSTOPPARALLEL Backpropagate weighted input derivatives to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  z1 = w*p; % SxQ
  z1 = reshape(z1,S,1,Q); % Sx1xQ
  p = reshape(p,1,R,Q); % 1xRxQ
  dz = reshape(dz,S,1,Q,N); % Sx1xQxN
  d = bsxfun(@times,2*z1,p); % SxRxQ
  dw = bsxfun(@times,d,dz); % SxRxQxN
end
