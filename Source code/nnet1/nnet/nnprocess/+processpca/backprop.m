function dx = backprop(dy,x,y,settings)
%PROCESSPCA.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  [~,Q,N] = size(dy);
  dy = reshape(dy,settings.yrows,Q*N);
  dx = settings.transform' * dy;
  dx = reshape(dx,settings.xrows,Q,N);
end
