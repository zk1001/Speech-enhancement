function dz = forwardprop(dp,w,p,z,param)
%SCALPROD.FORWARDPROP Propagate derivative from input to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  dz =  w .* dp;
end
