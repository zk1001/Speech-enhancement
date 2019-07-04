function dw = backstop(dz,w,p,z,param)
%NEGDIST.BACKSTOP Backpropagate weighted input derivative to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q] = size(dz);
  R = size(p,1);
  p = reshape(p,1,R,Q); % 1xRxQ
  z = reshape(z,S,1,Q); % Sx1xQ
  dz = reshape(dz,S,1,Q); % Sx1xQ
  d = bsxfun(@rdivide,bsxfun(@minus,w,p),z); % SxRxQ
  d(~isfinite(d)) = 0;
  dw = sum(bsxfun(@times,d,dz),3); % SxR
end
