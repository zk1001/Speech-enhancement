function y = apply(x,settings)
%MAPMINMAX.APPLY Process values

% Copyright 2012-2015 The MathWorks, Inc.

  y = bsxfun(@minus,x,settings.xoffset);
  y = bsxfun(@times,y,settings.gain);
  y = bsxfun(@plus,y,settings.ymin);
end
