function da = forwardprop(dn,n,a,param)
%RADBAS.FORWARDPROP Forward propagate derivatives from input to output.

% Copyright 2012-2015 The MathWorks, Inc.

  da = bsxfun(@times,dn,-2*n.*a);
end

