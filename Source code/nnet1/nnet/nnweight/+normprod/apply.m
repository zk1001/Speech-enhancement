function z = apply(w,p,param)
%NORMPROD.APPLY Apply weight to input

% Copyright 2012-2015 The MathWorks, Inc.

  p = p + 1e-20*sign(p);
  sump = sum(abs(p),1);
  sump(sump == 0) = 1;
  normp = bsxfun(@times,p,1 ./ sump);
  z = w * normp;
end

% Adding 1e-20 avoids the problem of zero length vectors.

% Multiplying by the reciprocal of sump instead of
% dividing by sump produces more accurate results and
% a better match with numerical derivatives.
