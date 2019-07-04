function dn = backprop(da,n,a,param)
%SATLINS.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  dn = bsxfun(@times,da,(n >= -1) & (n <= 1));
end
