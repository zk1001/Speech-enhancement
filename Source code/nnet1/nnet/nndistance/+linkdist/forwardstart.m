function dw = forwardstart(w,p,z,param)
%KINKDIST.FORWARDSTART Propagate derivative from weight to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,R] = size(w);
  Q = size(p,2);
  dw = zeros(S,Q,S,R,'like',w);
end