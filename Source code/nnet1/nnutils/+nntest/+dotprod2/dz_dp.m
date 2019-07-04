function d = dz_dp(w,p,z,param)
%DOTPROD2.DZ_DP Derivative of weighted input with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  z1 = w*p;
  [S,R] = size(w);
  Q = size(p,2);
  d = cell(1,Q);
  for q = 1:Q
    dq = zeros(S,R,'like',w);
    for i=1:S
      dq(i,:) = 2*z1(i,q)*w(i,:);
    end
    d{q} = dq;
  end
end
