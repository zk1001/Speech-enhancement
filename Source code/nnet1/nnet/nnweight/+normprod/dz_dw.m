function d = dz_dw(w,p,z,param)
%NORMPROD.DZ_DW Derivative of weighted input with respect to weight

% Copyright 2012-2015 The MathWorks, Inc.

  sump = sum(abs(p),1);
  dividep = 1 ./ sump;
  d = bsxfun(@times,p,dividep);
  d(~isfinite(d)) = 0;
end
