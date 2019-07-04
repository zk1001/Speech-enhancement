function dn = backprop(da,n,a,param)
%ELLIOT2SIG.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  n2 = n .* n;  
  d = 2*sign(n).*n ./ ((1+n2).^2);
  dn = bsxfun(@times,da,d);
end


