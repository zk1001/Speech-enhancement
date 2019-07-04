function dx = forwardpropReverse(dy,x,y,settings)
%MAPMINMAX.FORWARDPROPREVERSE Forward propagate reverse function derivatives

% Copyright 2012-2015 The MathWorks, Inc.

  dx = bsxfun(@rdivide,dy,settings.gain);
end
