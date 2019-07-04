function d = dz_dp(w,p,z,param)
%BOXDIST.DZ_DP Derivative of weighted input with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  S = size(w,1);
  [R,Q] = size(p);
  if (R==0)
    d = repmat({zeros(S,0,'like',w)},1,Q);
  else
    d = cell(1,Q);
    for q=1:Q
      z1 = bsxfun(@minus,p(:,q)',w); % SxR
      z2 = abs(z1); % SxR
      z3 = max(abs(z2),[],2); % Sx1
      dq = bsxfun(@eq,z2,z3) .* sign(z1); % SxR
      d{q} = dq;
    end
  end
end
