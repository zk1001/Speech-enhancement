function text = encloseText(front,text,back,skipEmpty)
% encloseText   Enclose a block of code with prefix and suffix lines

% Copyright 2012-2015 The MathWorks, Inc.

if nargin < 3, back = {}; end
if nargin < 4, skipEmpty = true; end

if skipEmpty && isempty(text)
  return
end

if ischar(front), front = {front}; end
if ischar(back), back = {back}; end
text = [front text back];

