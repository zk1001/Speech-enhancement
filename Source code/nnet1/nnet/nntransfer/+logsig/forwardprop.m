function da = forwardprop(dn,n,a,param)
%LOGSIG.FORWARDPROP Forward propagate derivatives from input to output.

% Copyright 2012-2015 The MathWorks, Inc.

  da = bsxfun(@times,dn,a.*(1-a));
end

