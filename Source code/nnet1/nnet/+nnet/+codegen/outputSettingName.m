function str = outputSettingName(i,j,field)
 
% Copyright 2012-2015 The MathWorks, Inc.

str = ['y' num2str(i) '_step' num2str(j)];
if (nargin >= 3)
  str = [str '.' field];
end
