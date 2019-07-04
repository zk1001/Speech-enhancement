function dx = backprop(dy,x,y,settings)
%MAPMINMAX.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  dx = bsxfun(@times,dy,settings.gain);
end