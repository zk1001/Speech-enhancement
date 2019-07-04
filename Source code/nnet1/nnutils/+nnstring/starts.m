function flag = starts(str,startStr)

% Copyright 2010 The MathWorks, Inc.

if length(str) < length(startStr)
  flag = false;
else
  flag = all(str(1:length(startStr)) == startStr);
end
