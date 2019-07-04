function dy = backpropReverse(dx,x,y,settings)
%REMOVECONSTANTROWS.BACKPROP_REVERSE  Backpropagate reverse function derivatives

% Copyright 2012-2015 The MathWorks, Inc.

  dy = dx(settings.keep,:,:,:);
end
