function text = commentText(text)
% commentText   Comment text

% Copyright 2012-2015 The MathWorks, Inc.

for i=1:numel(text)
  text{i} = ['% ' text{i}];
end
