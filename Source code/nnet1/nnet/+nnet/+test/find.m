function tests = find(testkey)
%FIND Find htests in given or working directory
%
%  FIND('testkey') will find all tests matching 'testkey'
%
%  The testkey can be the name of an htest function, the name of an
%  htest function without 'htest_', or the name of a test directory.
%
%  Examples:
%
%    nnet.test.find('htest_checkpoint')  % Single htest
%    nnet.test.find('checkpoint')  % Same result.
%    nnet.test.find('nninitweight')  % All htests in nninitweight

% Copyright 2013-2015 The MathWorks, Inc.

if nargin < 1, testkey = 'all'; end

% Find all H-tests
allTests = nnfile.files(fullfile(nnpath.nnet_root,'test'),'all');
for i=numel(allTests):-1:1
  [~,name,ext] = fileparts(allTests{i});
  if ~nnstring.starts(name,'htest_') || ~strcmp(ext,'.m')
    allTests(i) = [];
  end
end

% Return all H-tests
if strcmp(testkey,'all')
  tests = allTests;
  return
end

for i=1:numel(allTests)
  [testdir,testname,ext] = fileparts(allTests{i});
  [~,parentdir] = fileparts(testdir);
  
  % Return one test
  if strcmp(testname,testkey) && strcmp(ext,'.m')
    tests = allTests(i);
    return
    
  % Return test in directory
  elseif strcmp(parentdir,testkey)
    tests = findTestsInDir(testdir);
    return
  end
end

% Try prepending htest_
if ~nnstring.starts(testkey,'htest_')
  tests = nnet.test.find(['htest_' testkey]);
  
% Return no tests
else
  tests = {};
end

function tests = findTestsInDir(testPath)

tests = {};
files = dir(testPath);
for i=1:numel(files)
  name = files(i).name;
  if nnstring.starts(name,'htest_') && nnstring.ends(name,'.m')
    tests{end+1} = fullfile(testPath,name);
  end
end
