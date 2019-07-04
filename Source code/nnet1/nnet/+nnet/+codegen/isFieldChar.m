function flag = isFieldChar(c)
% isFieldChar   Test whether characters are legal within a structure field
% name

% Copyright 2012-2015 The MathWorks, Inc.

flag = ((c >= 'A') && (c <= 'Z')) ...
  || ((c >= 'a') && (c <= 'z')) ...
  || ((c >= '0') && (c <= '9')) ...
  || (c == '_');
end