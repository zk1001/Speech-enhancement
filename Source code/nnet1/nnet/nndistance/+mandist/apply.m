function z = apply(w,p,param)
%MANDIST.APPLY Apply weight to input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,R] = size(w);
  Q = size(p,2);
  p = reshape(p,1,R,Q); % 1xRxQ
  z = sum(abs(bsxfun(@minus,w,p)),2); % Sx1xQ
  z = reshape(z,S,Q); % SxQ
end
