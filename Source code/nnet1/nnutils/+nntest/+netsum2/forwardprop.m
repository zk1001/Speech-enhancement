function dn = forwardprop(dz,j,z,n,param)
%NETSUM2.FORWARDPROP Propagate derivates from weighted input to net input

% Copyright 2012-2015 The MathWorks, Inc.

dn = dz*param.alpha;
end
