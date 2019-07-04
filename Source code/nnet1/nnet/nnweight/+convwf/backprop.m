function dp = backprop(dz,w,p,z,param)
%CONVWF.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  dp = convn(dz,w,'full');
end
