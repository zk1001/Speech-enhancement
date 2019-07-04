function d = da_dn(n,a,param)
%TRIBAS.DA_DN Derivative of outputs with respect to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  d = ((n >= -1) & (n <= 1)) .* -sign(n);
end

