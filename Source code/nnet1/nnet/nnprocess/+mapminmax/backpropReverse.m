function dy = backpropReverse(dx,x,y,settings)
%MAPMINMAX.BACKPROPREVERSE Backpropagate reverse function derivatives

% Copyright 2012-2015 The MathWorks, Inc.

  dy = bsxfun(@rdivide,dx,settings.gain);
end