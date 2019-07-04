function y = apply(x,settings)
%MAPSTD.APPLY Process values

% Copyright 2013-2015 The MathWorks, Inc.

  y = bsxfun(@minus,x,settings.xoffset);
  y = bsxfun(@times,y,settings.gain);
  y = bsxfun(@plus,y,settings.ymean);
end
