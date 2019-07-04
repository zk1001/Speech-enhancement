function dn = backprop(da,n,a,param)
%RADBAS.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  dn = bsxfun(@times,da,-2*n.*a);
end
