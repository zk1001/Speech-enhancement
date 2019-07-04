function da = forwardprop(dn,n,a,param)
%NETINV.FORWARDPROP Forward propagate derivatives from input to output.

% Copyright 2012-2015 The MathWorks, Inc.

  da = bsxfun(@times,dn,max(-a.*a,-1e60));
end
