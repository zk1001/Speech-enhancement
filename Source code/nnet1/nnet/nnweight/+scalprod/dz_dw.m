function d = dz_dw(w,p,z,param)
%SCALPROD.DZ_DW Derivative of weighted input with respect to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [R,Q] = size(p);
  d = reshape(p,R,1,Q);
end
