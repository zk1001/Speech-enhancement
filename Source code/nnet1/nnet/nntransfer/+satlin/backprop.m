function dn = backprop(da,n,a,param)
%SATLIN.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  dn = bsxfun(@times,da,(n >= 0) & (n <= 1));
end



