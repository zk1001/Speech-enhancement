function y = apply(x,settings)
%FIXUNKNOWNS.APPLY Process values

  % Copyright 2012-2015 The MathWorks, Inc.
  
  Q = size(x,2);
  shiftInd = (1:settings.xrows) + settings.shift;
  flagInd = settings.unknown + settings.shift(settings.unknown) + 1;
  y = zeros(settings.yrows,Q,'like',x);
  isNaNX = isnan(x);
  meanX = repmat(settings.xmeans,1,Q);
  x(isNaNX) = meanX(isNaNX);
  y(shiftInd,:) = x;
  y(flagInd,:) = ~isNaNX(settings.unknown,:);
end
