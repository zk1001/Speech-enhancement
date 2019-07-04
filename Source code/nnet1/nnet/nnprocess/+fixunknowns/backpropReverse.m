function dy = backpropReverse(dx,x,y,settings)
%FIXUNKNOWNS.BACKPROPREVERSE Backpropagate propagate reverse function derivatives

% Copyright 2012-2015 The MathWorks, Inc.

  shiftInd = (1:settings.xrows) + settings.shift;
  sizes = size(dx);
  sizes(1) = settings.yrows;
  dy = zeros(sizes,'like',dx);
  dy(shiftInd,:,:) = bsxfun(@times,dx,~isnan(x));
end
