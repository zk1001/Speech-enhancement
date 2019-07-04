function [calcMode,err,modeSpecified] = options2Mode(net,nameValuePairs)

% Copyright 2013-2015 The MathWorks, Inc.

calcMode = [];
modeSpecified = false;

%=================== Override Default Options

options = nnet.options.calc.defaults;
options.reduction = net.efficiency.memoryReduction;
[options,err] = nnet.options.override(options,nameValuePairs);
if ~isempty(err), return; end
err = nnet.options.calc.check(options);
if ~isempty(err), return, end

% Checkpoint File Expand
options.CheckpointFile = nnet.checkpoint.expandFile(options.CheckpointFile);

%=================== Set Calculation Mode

% Mode Specified
if strcmp(options.useParallel,'yes'), modeSpecified = true; end
if ~strcmp(options.useGPU,'no'), modeSpecified = true; end
if (options.reduction ~= 1), modeSpecified = true; end

% Pick the calculation mode
if isdeployed
  calcMode = nnMATLAB;
elseif strcmp(options.useParallel,'yes') && ~strcmp(options.useGPU,'no')
  calcMode = nnParallel('subcalc',nnGPUOp('precision',options.precision),...
    'onlyGPUs',strcmp(options.useGPU,'only'),'direction',options.direction);
elseif strcmp(options.useParallel,'yes')
  calcMode = nnParallel('subcalc',MexOrMATLAB(net,options),'direction',options.direction);
elseif ~strcmp(options.useGPU,'no')
  calcMode = nnGPUOp('precision',options.precision);
else
  calcMode = MexOrMATLAB(net,options);
end

%=================== Set Other Options

calcMode.options = options;

%===================

function calcMode = MexOrMATLAB(net,options)
calcMode = nncalc.defaultMode(net,[]);
calcMode.hints.direction = options.direction;
if (options.reduction > 1) && ~strcmp(calcMode.mode,'nnMex')
  calcMode = nnMemReduc('reduction',options.reduction,'subcalc',calcMode);
end
