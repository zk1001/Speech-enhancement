function dz = dz_dw(w,p,z,param)
%LINKDIST.DZ_DW Derivative of weighted input with respect to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [R,Q] = size(p);
  dz = zeros(R,Q,'like',w);
end
