function str = operatorList(list,op)
% operatorList   Combine strings with operators between them

% Copyright 2012-2015 The MathWorks, Inc.

if isempty(list)
  str = '';
else
  str = list{1};
  for i=2:numel(list)
    str = [str op list{i}];
  end
end
