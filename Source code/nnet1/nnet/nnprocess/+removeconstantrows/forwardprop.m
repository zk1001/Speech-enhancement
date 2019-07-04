function dy = forwardprop(dx,x,y,settings)
%REMOVECONSTANTROWS.FORWARDPROP Forward propagate derivatives from inputs to outputs

% Copyright 2012-2015 The MathWorks, Inc.

  dy = dx(settings.keep,:,:,:);
end
