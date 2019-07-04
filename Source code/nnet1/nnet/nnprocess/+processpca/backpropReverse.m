function dy = backpropReverse(dx,x,y,settings)
%PROCESSPCA.BACKPROPREVERSE Backpropagate propagate reverse function derivatives

% Copyright 2012-2015 The MathWorks, Inc.

  [~,Q,N] = size(dx);
  dx = reshape(dx,settings.xrows,Q*N);
  dy = settings.inverseTransform' * dx;
  dy = reshape(dy,settings.yrows,Q,N);
end
