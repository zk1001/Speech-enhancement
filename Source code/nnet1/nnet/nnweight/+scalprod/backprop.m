function dp = backprop(dz,w,p,z,param)
%SCALPROD.BACKPROP Backpropagate weighted input derivative to input

% Copyright 2012-2015 The MathWorks, Inc.

  dp = w .* dz;
end
