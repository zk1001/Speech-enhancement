function dz = forwardprop(dp,w,p,z,param)
%DIST.FORWARDPROP Propagate derivative from input to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  [~,Q,N] = size(dp);
  S = size(z,1);
  dz = zeros(S,Q,N,'like',dp);
end