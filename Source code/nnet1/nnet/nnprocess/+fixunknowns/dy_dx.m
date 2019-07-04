function d = dy_dx(x,y,settings)
%FIXUNKNOWNS.DY_DX Derivatives of output with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  R = settings.xrows;
  Q = size(x,2);
  d = cell(1,Q);
  notNaNX = ~isnan(x);
  shiftInd = (1:R) + settings.shift;
  for q=1:Q
    dq = zeros(settings.yrows,settings.xrows,'like',x);
    dq(shiftInd,:) = diag(notNaNX(:,q));
    d{q} = dq;
  end
end
