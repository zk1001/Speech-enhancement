function dy = forwardprop(dx,x,y,settings)
%PROCESSPCA.FORWARDPROP Forward propagate derivatives from inputs to outputs

% Copyright 2012-2015 The MathWorks, Inc.

  [~,Q,N] = size(dx);
  dx = reshape(dx,settings.xrows,Q*N);
  dy = settings.transform * dx;
  dy = reshape(dy,settings.yrows,Q,N);
end
