function dw = backstop(dz,w,p,z,param)
%MANDIST.BACKSTOP Backpropagate weighted input derivative to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q] = size(dz);
  R = size(p,1);
  p = reshape(p,1,R,Q); % 1xRxQ
  dz = reshape(dz,S,1,Q); % Sx1xQ
  z1 = bsxfun(@minus,w,p); % SxRxQ
  d = sign(z1); % SxRxQ
  dw = sum(bsxfun(@times,d,dz),3); % SxR
end