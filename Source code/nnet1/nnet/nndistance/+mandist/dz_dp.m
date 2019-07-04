function d = dz_dp(w,p,z,param)
%MANDIST.DZ_DP Derivative of weighted input with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  Q = size(p,2);
  d = cell(1,Q);
  for q=1:Q
    z1 = bsxfun(@minus,p(:,q)',w);
    d{q} = sign(z1);
  end
end
