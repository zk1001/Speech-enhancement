function dx = forwardpropReverse(dy,x,y,settings)
%PROCESSPCA.FORWARDPROP_REVERSE Forward propagate reverse function derivatives

% Copyright 2012-2015 The MathWorks, Inc.

  [~,Q,N] = size(dy);
  dy = reshape(dy,settings.yrows,Q*N);
  dx = settings.inverseTransform * dy;
  dx = reshape(dx,settings.xrows,Q,N);
end
