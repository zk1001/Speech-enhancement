function err = isLegalVariableName(name)

% Copyright 2013 The MathWorks, Inc.

if isempty(name)
  err = 'Variable name is empty';
elseif ~ischar(name)
  err = 'Variable name is not a character vector.';
elseif (size(name,1) ~= 1) || ~ismatrix(name)
  err = 'Variable name is not a character row vector.';
else
  isLower = (name >= 'a') & (name <= 'z');
  isUpper = (name >= 'A') & (name <= 'Z');
  isDigit = (name >= '0') & (name <= '9');
  isUnderbar = (name == '_');
  
  if ~all(isLower | isUpper | isDigit | isUnderbar)
    err = 'Variable name contains non-alphanumeric or underbar characters.';
    
  elseif isDigit(name(1))
    err = 'Variable name starts with a numeric digit.';
  
  elseif isUnderbar(name(1))
    err = 'Variable name starts with a numeric digit.';
    
  else
    err = '';
  end
end
