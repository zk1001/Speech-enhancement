function d = da_dn(n,a,param)
%TANSIG2.DA_DN Derivative of outputs with respect to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  d = param.alpha*(1-(a.*a));
end