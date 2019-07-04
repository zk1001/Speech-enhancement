function d = dy_dx(x,y,settings)
%LVQOUTPUTS.DY_DX Derivatives of output with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  Q = size(x,2);
  d = eye(settings.xrows,'like',x);
  d = repmat({d},1,Q);
end
