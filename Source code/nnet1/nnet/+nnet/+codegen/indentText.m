function text = indentText(text,n)
% indentText   Indent text

% Copyright 2012-2015 The MathWorks, Inc.

if nargin < 2
  n = 1;
end

spaces = repmat(' ',1,n*4);
for i=1:numel(text)
  text{i} = [spaces text{i}];
end
