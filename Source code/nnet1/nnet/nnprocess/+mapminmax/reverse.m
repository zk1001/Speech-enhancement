function x = reverse(y,settings)
%MAPMINMAX.REVERSE Reverse process values

% Copyright 2012-2015 The MathWorks, Inc.

  x = bsxfun(@minus,y,settings.ymin);
  x = bsxfun(@rdivide,x,settings.gain);
  x = bsxfun(@plus,x,settings.xoffset);
end
