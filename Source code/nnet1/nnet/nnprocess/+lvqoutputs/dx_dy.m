function d = dx_dy(x,y,settings)
%LVQOUTPUTS.DX_DY Derivatives of input with respect to output

% Copyright 2012-2015 The MathWorks, Inc.

  Q = size(x,2);
  d = eye(settings.xrows,'like',x);
  d = repmat({d},1,Q);
end
