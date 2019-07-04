function d = da_dn(n,a,param)
%ELLIOT2SIG.DA_DN Derivative of outputs with respect to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  n2 = n .* n;  
  d = 2*sign(n).*n ./ ((1+n2).^2);
end
