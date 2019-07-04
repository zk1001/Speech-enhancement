function d = dx_dy(x,y,settings)
%FIXUNKNOWNS.DX_DY Derivatives of input with respect to output

% Copyright 2012-2015 The MathWorks, Inc.

  Q = size(x,2);
  d = cell(1,Q);
  notNaNX = ~isnan(x);
  for q=1:Q
    dq = zeros(settings.xrows,settings.yrows,'like',x);
    dq(:,(1:settings.xrows)+settings.shift) = diag(notNaNX(:,q));
    d{q} = dq;
  end
end
