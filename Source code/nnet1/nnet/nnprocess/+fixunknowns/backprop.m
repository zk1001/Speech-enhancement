function dx = backprop(dy,x,y,settings)
%FIXUNKNOWNS.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  shiftInd = (1:settings.xrows) + settings.shift;
  dx = bsxfun(@times,dy(shiftInd,:,:),~isnan(x));
end
