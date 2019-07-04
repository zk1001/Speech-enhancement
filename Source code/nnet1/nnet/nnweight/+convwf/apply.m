function z = apply(w,p,param)
%CONVWF.APPLY Apply weight to input

% Copyright 2012-2015 The MathWorks, Inc.

  z = convn(p,flipud(w),'valid');
end
