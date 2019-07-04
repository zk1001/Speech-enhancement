function text = combineTextBlocks(blocks,insertBlanks)
% combineTextBlocks   Merge text blocks with optional blank lines between
% them

% Copyright 2012-2015 The MathWorks, Inc.

if nargin < 2
  insertBlanks = true;
end

if insertBlanks
  blank = {''};
else
  blank = {};
end

% Remove empty blocks
for i=numel(blocks):-1:1
  if isempty(blocks{i})
    blocks(i) = [];
  end
end

% Remove end blanks
for i=1:numel(blocks)
  if isempty(blocks{i}{end})
    blocks{i}(end) = [];
  end
end

% Combine blocks
text = {};
if ~isempty(blocks)
  text = blocks{1};
  for i=2:numel(blocks)
    text = [text blank blocks{i}];
  end
end
