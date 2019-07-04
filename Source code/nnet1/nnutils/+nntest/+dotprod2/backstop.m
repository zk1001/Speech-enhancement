function dw = backstop(dz,w,p,z,param)
%DOTPROD2.BACKSTOP Backpropagate weighted input derivative to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q] = size(dz);
  R = size(p,1);
  z1 = w*p; % SxQ
  z1 = reshape(z1,S,1,Q); % Sx1xQ
  p = reshape(p,1,R,Q); % 1xRxQ
  dz = reshape(dz,S,1,Q); % Sx1xQ
  d = bsxfun(@times,2*z1,p); % SxRxQ
  dw = sum(bsxfun(@times,d,dz),3); % SxR
end