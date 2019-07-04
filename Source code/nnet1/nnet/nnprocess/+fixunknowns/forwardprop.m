function dy = forwardprop(dx,x,y,settings)
%FIXUNKNIWNS.FORWARDPROP Forward propagate derivatives from inputs to outputs

% Copyright 2012-2015 The MathWorks, Inc.

  shiftInd = (1:settings.xrows) + settings.shift;
  sizes = size(dx);
  sizes(1) = settings.yrows;
  dy = zeros(sizes,'like',dx);
  dy(shiftInd,:,:,:) = bsxfun(@times,dx,~isnan(x));
end
