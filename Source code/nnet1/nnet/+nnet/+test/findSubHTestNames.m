function names = findSubHTestNames(htest,prefix)

% Copyright 2013-2015 The MathWorks, Inc.

if nargin < 2, prefix = ''; end

% Constants
ALPHANUMERIC = ['a':'z' 'A':'Z' '0':'9' '_'];

% Prefix is empty string if not supplied or 'lvlAll'
if nargin < 1, prefix = ''; end
if strcmp(prefix,'lvlAll'), prefix = ''; end

% Find subtests that match testing prefix
names = {};
if ~nnstring.ends(htest,'.m')
  htest = [htest '.m'];
end
text = nntext.load(htest);
for i=2:numel(text)
  str = text{i};
  
  % Find function name
  if any((str == '%') | (str == '''')) % Skip lines with comments or strings
    testName = '';
    continue
  end
  fcnstr = 'function ';
  j = strfind(str,fcnstr);
  if isempty(j) % Skip lines with no function keyword
    testName = '';
    continue
  end
  str(1:(j+numel(fcnstr)-1)) = [];
  j = find(str == '(')-1;
  if isempty(j), j = numel(str); end
  while (j>0) && (str(j) == ' ') % Backup to last character of name
    j = j - 1;
  end
  if (j == 0) % Skip if somehow there is no function name
    testName = '';
    continue
  end
  k = j;
  while (k>1) && any(str(k-1) == ALPHANUMERIC) % Backup to first character of name
    k = k - 1;
  end
  testName = str(k:j);
  
  % Check prefix and convert to function handle
  if ~isempty(testName) && (isempty(prefix) || nnstring.starts(testName,prefix)) ...
      &&  nnstring.starts(testName,'lvl')
    names{end+1} = testName;
  end
end
