function z = apply(w,p,param)
%DOTPROD3.APPLY Apply weight to input

% Copyright 2012-2015 The MathWorks, Inc.

  z = param.alpha + param.beta*w*p;
end
