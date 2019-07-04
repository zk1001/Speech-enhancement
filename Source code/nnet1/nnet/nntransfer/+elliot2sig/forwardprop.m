function da = forwardprop(dn,n,a,param)
%ELLIOT2SIG.FORWARDPROP Forward propagate derivatives from input to output.

% Copyright 2012-2015 The MathWorks, Inc.

  n2 = n .* n;  
  d = 2*sign(n).*n ./ ((1+n2).^2);
  da = bsxfun(@times,dn,d);
end
