function dp = backprop(dz,w,p,z,param)
%LINKDIST.BACKPROP Backpropagate weighted input derivative to input

% Copyright 2012-2015 The MathWorks, Inc.


  [~,Q,N] = size(dz);
  R = size(p,1);
  dp = zeros(R,Q,N,'like',w);
end
