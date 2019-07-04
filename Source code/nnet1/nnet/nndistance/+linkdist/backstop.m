function dw = backstop(dz,w,p,z,param)
%LINKDIST.BACKSTOP Backpropagate weighted input derivative to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,R] = size(w);
  dw = zeros(S,R,'like',dz);
end
