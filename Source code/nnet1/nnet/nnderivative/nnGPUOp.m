function tools = nnGPUOp(varargin)

% Copyright 2012 The MathWorks, Inc.

% Mode
tools.mode = mfilename;

% Default Hints
hints.name = '';
hints.subcalc.name = 'default'; % 'none', 'default', calcMode
hints.defaultToCPU = true;
hints.precision = 'double';

% Override Default Hints
hints = nncalc.argPairs2Struct(hints,varargin);

% Name
if isempty(hints.name)
  hints.name = 'GPUOp';
end

tools.hints = hints;
tools.name = hints.name;

% Function Handles
tools.summary = @nnGPUOp.summary;
tools.netCheck = @nnGPUOp.netCheck;

tools.netHints = @nnGPUOp.netHints;
tools.dataHints = @nnGPUOp.dataHints;
tools.codeHints = @nnGPUOp.codeHints;

tools.formatNet = @nnGPUOp.formatNet;
tools.formatData = @nnGPUOp.formatData;

tools.setwb = @nnGPUOp.setwb;
tools.getwb = @nnGPUOp.getwb;

tools.pc = @nnGPUOp.pc;
tools.pd = ''; % TODO - GPU VERSION
tools.y = @nnGPUOp.y;

tools.trainPerf = @nnGPUOp.trainPerf;
tools.trainValTestPerfs = @nnGPUOp.trainValTestPerfs;

tools.grad = @nnGPUOp.grad;
tools.perfsJEJJ = @nnGPUOp.perfsJEJJ;
tools.perfsGrad = @nnGPUOp.perfsGrad;


