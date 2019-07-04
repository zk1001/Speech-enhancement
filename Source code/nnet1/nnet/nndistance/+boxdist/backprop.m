function dp = backprop(dz,w,p,z,param)
%BOXDIST.BACKPROP Backpropagate weighted input derivative to input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  p = reshape(p,1,R,Q); % 1xRxQ
  dz = reshape(dz,S,1,Q,N); % Sx1xQxN
  z1 = bsxfun(@minus,p,w); % SxRxQ
  z2 = abs(z1); % SxRxQ
  z3 = max(abs(z2),[],2); % Sx1xQ
  d = bsxfun(@eq,z2,z3) .* sign(z1); % SxRxQ
  dp = sum(bsxfun(@times,d,dz),1); % 1xRxQxN
  dp = reshape(dp,R,Q,N); % RxQxN
end