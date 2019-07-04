function d = dy_dx(x,y,settings)
%REMOVEROWS.DY_DX Derivatives of output with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  Q = size(x,2);
  d = zeros(settings.yrows,settings.xrows,'like',x);
  for i=1:length(settings.keep_ind)
    d(i,settings.keep_ind(i)) = 1;
  end
  d = repmat({d},1,Q);
end
