function x = reverse(y,settings)
%REMOVECONSTANTROWS.REVERSE Reverse process values

% Copyright 2012-2015 The MathWorks, Inc.

  Q = size(y,2);
  x = nan(settings.xrows,Q,'like',y);
  x(settings.keep,:) = y;
  x(settings.remove,:) = repmat(settings.constants,1,Q);
end
