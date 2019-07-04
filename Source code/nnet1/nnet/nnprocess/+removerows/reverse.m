function x = reverse(y,settings)
%REMOVEROWS.REVERSE Reverse process values

% Copyright 2012-2015 The MathWorks, Inc.

  Q = size(y,2);
  x = nan(settings.xrows,Q,'like',y);
  x(settings.keep_ind,:) = y;
end
