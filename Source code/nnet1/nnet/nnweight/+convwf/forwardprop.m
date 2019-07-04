function dz = forwardprop(dp,w,p,z,param)
%CONVWF.FORWARDPROP Forward propagate derivatives from inputs to outputs

% Copyright 2012-2015 The MathWorks, Inc.

  dz = convn(dp,flipud(w),'valid');
end