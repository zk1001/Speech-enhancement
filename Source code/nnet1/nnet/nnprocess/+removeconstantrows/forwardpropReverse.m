function dx = forwardpropReverse(dy,x,y,settings)
%REMOVECONSTANTROWS.FORWARDPROPREVERSE Forward propagate reverse function derivatives

% Copyright 2012-2015 The MathWorks, Inc.

  sizes = size(dy);
  sizes(1) = settings.xrows;
  dx = zeros(sizes,'like',dy);
  dx(settings.keep,:,:,:) = dy;
end
