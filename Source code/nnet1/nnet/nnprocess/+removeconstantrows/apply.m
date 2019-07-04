function y = apply(x,settings)
%REMOVECONSTANTROWS.APPLY Process values

  % Copyright 2012-2015 The MathWorks, Inc.

  y = x(settings.keep,:);
end
