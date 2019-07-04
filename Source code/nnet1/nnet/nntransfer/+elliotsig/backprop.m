function dn = backprop(da,n,a,param)
%ELLIOTSIG.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  d = 1 ./ ((1+abs(n)).^2);
  dn = bsxfun(@times,da,d);
end
