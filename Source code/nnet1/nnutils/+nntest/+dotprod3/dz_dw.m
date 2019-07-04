function d = dz_dw(w,p,z,param)
%DOTPROD3.DZ_DW Derivative of weighted input with respect to weight

% Copyright 2012-2015 The MathWorks, Inc.

  d = param.beta*p;
end
