function d = dz_dw(w,p,z,param)
%MANDIST.DZ_DW Derivative of weighted input with respect to weight

% Copyright 2012-2015 The MathWorks, Inc.

  S = size(w,1);
  d = cell(1,S);
  for i=1:S
    z1 = bsxfun(@minus,w(i,:)',p);
    d{i} = sign(z1);
  end
end
