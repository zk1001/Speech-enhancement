function da = forwardprop(dn,n,a,param)
%TRIBAS.FORWARDPROP Forward propagate derivatives from input to output.

% Copyright 2012-2015 The MathWorks, Inc.

  da = bsxfun(@times,dn,((n >= -1) & (n <= 1)) .* -sign(n));
end

