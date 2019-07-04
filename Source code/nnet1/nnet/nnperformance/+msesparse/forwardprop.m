function dperf = forwardprop(dy,t,y,e,param)
%MSESPARSE.FORWARDPROP Forward propagate derivatives to performance

% Copyright 2012-2015 The MathWorks, Inc.

  dperf = bsxfun(@times,dy,-2*e);
end
