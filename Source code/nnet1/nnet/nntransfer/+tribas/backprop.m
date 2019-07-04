function dn = backprop(da,n,a,param)
%TRIBAS.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  dn = bsxfun(@times,da,((n >= -1) & (n <= 1)) .* -sign(n));
end
