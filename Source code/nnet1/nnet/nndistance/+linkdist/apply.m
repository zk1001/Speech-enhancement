function z = apply(w,p,param)
%LINKDIST.APPLY Apply weight to input

% Copyright 2012-2015 The MathWorks, Inc.

  S = size(w,1);
  Q = size(p,2);
  z = zeros(S,Q,'like',w);
end
