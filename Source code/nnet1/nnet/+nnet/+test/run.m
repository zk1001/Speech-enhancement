function out = run(testkey,prefix)
%Run HTESTS
%
%  nnet.test.run, runs all htests in working directory
%  nnet.test.run(dir), runs all htests in dir
%  nnet.test.run(htest), runs htest
%  nnet.test.run(htest,prefix), runs subtests of htest with given prefix

% Copyright 2013-2015 The MathWorks, Inc.

if nargin < 2, prefix = ''; end
if (nargin < 1) || isempty(testkey)
  nnet.test.run(pwd,'');
  return
end

tests = nnet.test.find(testkey);
if isempty(tests)
  disp('No tests found.')
  pass = true;
else  
  saveWorkingDir = pwd;
  for i=1:numel(tests)
    [testdir,testname] = fileparts(tests{i});
    cd(testdir)
    if isempty(prefix)
      pass = feval(testname);
    else
      pass = feval(testname,prefix);
    end
  end
  cd(saveWorkingDir);
end
if nargout > 1, out = pass; end
