function dp = backprop(dz,w,p,z,param)
%NEGDIST.BACKPROP Backpropagate weighted input derivative to input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  p = reshape(p,1,R,Q); % 1xRxQ
  z = reshape(z,S,1,Q); % Sx1xQ
  dz = reshape(dz,S,1,Q,N); % Sx1xQxN
  d = bsxfun(@rdivide,bsxfun(@minus,p,w),z); % SxRxQ
  d(~isfinite(d)) = 0;
  dp = sum(bsxfun(@times,d,dz),1); % 1xRxQxN
  dp = reshape(dp,R,Q,N); % RxQxN
end
