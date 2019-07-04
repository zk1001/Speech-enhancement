function dn = backprop(da,n,a,param)
%NETINV.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  dn = bsxfun(@times,da,max(-a.*a,-1e60));
end
