function dz = forwardprop(dp,w,p,z,param)
%DOTPROD2.FORWARDPROP Forward propagate derivatives from inputs to outputs

% Copyright 2012-2015 The MathWorks, Inc.

  [R,Q,N] = size(dp);
  S = size(z,1);
  p = reshape(p,1,R,Q); % 1xRxQ
  dp = reshape(dp,1,R,Q,N); % 1xRxQxN
  d = bsxfun(@times,2*sum(bsxfun(@times,w,p),2),w); % SxRxQ
  dz = sum(bsxfun(@times,d,dp),2); % Sx1xQxN
  dz = reshape(dz,S,Q,N); % SxQxN
end
