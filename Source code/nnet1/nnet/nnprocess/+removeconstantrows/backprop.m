function dx = backprop(dy,x,y,settings)
%REMOVECONSTANTROWS..BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  sizes = size(dy);
  sizes(1) = settings.xrows;
  dx = zeros(sizes,'like',dy);
  dx(settings.keep,:,:,:) = dy;
end
