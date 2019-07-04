function dz = backprop(dn,j,z,n,param)
%NETSUM2.BACKPROP Propagate derivates from net input back to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

dz = dn*param.alpha;
end
