function x = reverse(y,settings)
%FIXUNKNOWNS.REVERSE Reverse process values

% Copyright 2012-2015 The MathWorks, Inc.

  shiftInd = (1:settings.xrows) + settings.shift;
  flagInd = settings.unknown + settings.shift(settings.unknown) + 1;
  unknownFlags = y(flagInd,:) < 0.5;
  unknownMask = ones(size(unknownFlags),'like',y);
  unknownMask(unknownFlags) = NaN;
  x = y(shiftInd,:);
  x(settings.unknown,:) = x(settings.unknown,:) .* unknownMask;
end
