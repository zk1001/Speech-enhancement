function out = runSubHTests(htestpath,subtests)

% Copyright 2013-2015 The MathWorks, Inc.

[~,htest,~] = fileparts(htestpath);

% Run subtest
passAll = true;
for i=1:numel(subtests)
  test = subtests{i};
  testName = func2str(test);
  testCall = ['nnet.test.run(''' htest ''',''' testName ''')'];
  testLink = ['<a href="matlab:' testCall '">' testCall '</a>'];
  disp(['Running: ' testLink]);
  
  % Initial State
  warnState = warning;
  randState = rng(0,'twister');
  workDir = pwd;
  nnet.test.flags('clear');
  
  try
    test();
  catch me
    testCall = [htest '(''' testName ''')'];
    errpath = me.stack(1).file;
    errline = num2str(me.stack(1).line);
    errLink = ['<a href="matlab:opentoline(''' errpath ''',' errline ',0)">' testCall '</a>'];
    disp('*****')
    disp(['***** ERROR IN TEST AT LINE ' errline ': ' errLink]);
    disp('*****')
    disp(me.getReport('basic','hyperlinks','off'))
    disp(' ')
    passAll = false;
  end
  
  % Return State
  nnet.guis.closeAllViews;
  close all
  warning(warnState);
  cd(workDir);
  rng(randState)
  nnet.test.flags('clear');
end

% Return pass value
if nargout > 0
  out = passAll;
end