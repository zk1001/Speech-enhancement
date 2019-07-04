function da = forwardprop(dn,n,a,param)
%TANSIG2.FORWARDPROP Derivative of outputs with respect to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  da = bsxfun(@times,dn,param.alpha*(1-(a.*a)));
end
