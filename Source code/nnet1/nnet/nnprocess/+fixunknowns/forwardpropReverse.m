function dx = forwardpropReverse(dy,x,y,settings)
%FIXUNKNOWNS.FORWARDPROP_REVERSE Forward propagate reverse function derivatives

% Copyright 2012-2015 The MathWorks, Inc.

  shiftInd = (1:settings.xrows) + settings.shift;
  dx = bsxfun(@times,dy(shiftInd,:,:),~isnan(x));
end
