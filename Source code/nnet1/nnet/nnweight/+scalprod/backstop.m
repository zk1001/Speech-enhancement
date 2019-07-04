function dw = backstop(dz,w,p,z,param)
%SCALPROD.BACKSTOP Backpropagate weighted input derivative to weight

% Copyright 2012-2015 The MathWorks, Inc.

  dw = bsxfun(@times,dz,p);
  dw = sum(dw(:));
end
