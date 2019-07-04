function tools = nnMemReduc(varargin)

% Copyright 2012 The MathWorks, Inc.

% Mode
tools.mode = mfilename;

% Default Hints
hints.name = '';
hints.reduction = 10;
hints.subcalc = nn7;

% Override Default Hints
hints = nncalc.argPairs2Struct(hints,varargin);

% Name
if isempty(hints.name)
  hints.name = ['Memory Reduction(' num2str(hints.reduction) ')'];
end
tools.hints = hints;
tools.name = hints.name;

% Function Handles
tools.summary = @nnMemReduc.summary;
tools.netCheck = @nnMemReduc.netCheck;

tools.netHints = @nnMemReduc.netHints;
tools.dataHints = @nnMemReduc.dataHints;
tools.codeHints = @nnMemReduc.codeHints;

tools.formatData = @nnMemReduc.formatData;
tools.formatNet = @nnMemReduc.formatNet;

tools.setwb = @nnMemReduc.setwb;
tools.getwb = @nnMemReduc.getwb;

tools.trainPerf = @nnMemReduc.trainPerf;
tools.trainValTestPerfs = @nnMemReduc.trainValTestPerfs;

tools.pc = @nnMemReduc.pc;
tools.pd = @nnMemReduc.pd;
tools.y = @nnMemReduc.y;

tools.grad = @nnMemReduc.grad;
tools.perfsJEJJ = @nnMemReduc.perfsJEJJ;
tools.perfsGrad = @nnMemReduc.perfsGrad;
