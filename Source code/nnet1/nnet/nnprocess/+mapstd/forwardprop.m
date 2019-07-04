function dy = forwardprop(dx,x,y,settings)
%MAPSTD.FORWARDPROP Forward propagate derivatives from inputs to outputs

% Copyright 2012-2015 The MathWorks, Inc.

  dy = bsxfun(@times,dx,settings.gain);
end
