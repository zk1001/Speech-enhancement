function list = numberedStrings(str,num)
% numberedStrings   Generate numbered list of strings, such as 'x1', 'x2,
% etc.

% Copyright 2012-2015 The MathWorks, Inc.

list = cell(1,num);
for i=1:num
  list{i} = [str num2str(i)];
end
