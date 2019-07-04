function z = apply(w,p,param)
%BOXDIST.APPLY Apply weight to input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,R] = size(w);
  Q = size(p,2);
  if (R==0)
    z = zeros(S,Q,'like',w);
  else
    isNaN = any(isnan(p),1);
    p(:,isNaN) = NaN;
    p = reshape(p,1,R,Q); % 1xRxQ
    z = max(abs(bsxfun(@minus,w,p)),[],2); % SxRxQ
    z = reshape(z,S,Q); % SxQ
  end
end
