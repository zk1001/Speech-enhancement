function d = da_dn(n,a,param)
%COMPET.DA_DN Derivative of outputs with respect to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q] = size(a);
  z = zeros(S,S,'like',n);
  d = repmat({z},1,Q);
end
