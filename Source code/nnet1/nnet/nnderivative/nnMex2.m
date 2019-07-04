function tools = nnMex2(varargin)

% Copyright 2012 The MathWorks, Inc.

% Mode
tools.mode = mfilename;

% Default Hints
hints.name = '';
hints.direction = 'default';
hints.batch = 32;

% Override Default Hints
hints = nncalc.argPairs2Struct(hints,varargin);
hints.precision = 'double';

% Name
if isempty(hints.name)
  hints.name = 'MEX2';
  if ~strcmp(hints.direction,'default')
    hints.name = [hints.name '(' hints.direction ')'];
  end
end
tools.hints = hints;
tools.name = hints.name;

% Function Handles
tools.summary = @nnMex2.summary;
tools.netCheck = @nnMex2.netCheck;

tools.netHints = @nnMex2.netHints;
tools.dataHints = @nnMex2.dataHints;
tools.codeHints = @nnMex2.codeHints;

tools.formatData = @nnMex2.formatData;
tools.formatNet = @nnMex2.formatNet;

tools.setwb = @nnMex2.setwb;
tools.getwb = @nnMex2.getwb;

tools.pc = @nnMATLAB.pc; % TODO - C VERSION
tools.pd = @nnMATLAB.pd; % TODO - C VERSION
tools.y = @nnMex2.y;

tools.trainPerf = @nnMex2.trainPerf;
tools.trainValTestPerfs = @nnMex2.trainValTestPerfs;

tools.grad = @nnMex2.grad;
tools.perfsJEJJ = @nnMex2.perfsJEJJ;
tools.perfsGrad = @nnMex2.perfsGrad;


