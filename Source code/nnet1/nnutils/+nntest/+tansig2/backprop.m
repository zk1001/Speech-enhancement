function dn = backprop(da,n,a,param)
%TANSIG2.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  dn = bsxfun(@times,da,param.alpha*(1-(a.*a)));
end
