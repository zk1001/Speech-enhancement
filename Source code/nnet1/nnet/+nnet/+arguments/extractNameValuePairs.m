function [args,nameValueParis] = extractNameValuePairs(args)

% Copyright 2013-2015 The MathWorks, Inc.

% Extract option-value pairs
pos = numel(args)+1;
while (pos-2) > 0
  if ischar(args{pos-2})
    pos = pos - 2;
  else
    break;
  end
end

nameValueParis = args(pos:end);
args = args(1:(pos-1));
