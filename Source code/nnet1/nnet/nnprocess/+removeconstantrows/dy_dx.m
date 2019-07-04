function d = dy_dx(x,y,settings)
%REMOVECONSTANTROWS.DY_DX Derivatives of output with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  Q = size(x,2);
  d = zeros(settings.yrows,settings.xrows,'like',x);
  ind = (1:settings.yrows) + ((settings.keep-1) * settings.yrows);
  d(ind) = 1;
  d = repmat({d},1,Q);
end
