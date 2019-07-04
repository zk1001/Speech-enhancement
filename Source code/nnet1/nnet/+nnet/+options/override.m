function [options,err] = override(options,nameValuePairs)

% Copyright 2013-2015 The MathWorks, Inc.

optionNames = fieldnames(options);
lowerOptionNames = lower(optionNames);

for i=1:2:numel(nameValuePairs)
  name = nameValuePairs{i};
  value = nameValuePairs{i+1};
  j = nnstring.match(lower(name),lowerOptionNames);
  if isempty(j)
    err = ['The string ''' name ''' is not a recognized option name.'];
    return
  end
  options.(optionNames{j}) = value;
end

err = '';
