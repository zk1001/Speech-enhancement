function dw = backstop(dz,w,p,z,param)
%DOTPROD.BACKSTOP Backpropagate weighted input derivative to weight

% Copyright 2012-2015 The MathWorks, Inc.

  dw = dz * p';
end