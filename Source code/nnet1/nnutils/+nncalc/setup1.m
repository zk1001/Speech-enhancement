function [calcMode,calcNet,calcData,calcHints,net,resourceText] = setup1(calcMode,net,data)
% First step of setup for calculation mode, net, data & hints for
% parallel or non-parallel calculations.  Must be called outside of SPMD.

% Copyright 2012-2015 The MathWorks, Inc.


% Fill in missing Options with defaults
if isfield(calcMode,'options')
  op = calcMode.options;
  calcMode.options = op;
else
  op = nnet.options.calc.defaults;
end

% Setup
[calcMode,calcNet,calcData,calcHints,net,resourceText] = setupImpl(calcMode,net,data);

% Ensure options remain after a mode change
if isa(calcMode,'Composite')
  spmd
    calcMode.options = op;
  end
else
  calcMode.options = op;
end

function [calcMode,calcNet,calcData,calcHints,net,resourceText] = setupImpl(calcMode,net,data)

if isfield(calcMode,'options')
  showResources = strcmp(calcMode.options.showResources,'yes');
else
  showResources = false;
end

% PRUNE NETWORK
% =============
% Pruning does not changes number of input or layer delays
% even if a zero sized connection with delays is pruned.
% So number of steps in Xi and Ai do not need to be updated.
net = struct(net);
net = nnet.codegen.weedProcessSteps(net);
net = nnet.nn.pruneEmptyWeights(net);

%% CHANGE TOP PARALLEL/GPU CALC MODE IF REQUIRED BY DATA
% ======================================================

% If Composite data => Add top mode nnParallel
isComposite = isa(data,'Composite');
if isComposite && ~strcmp(calcMode.mode,'nnParallel')
  calcMode = nnParallel('subcalc',calcMode);
end

% If gpuArray data => Change top mode is nnGPU
isGPUArray = ~isComposite && isa(data.X,'gpuArray');
if isGPUArray && ~strcmp(calcMode.mode,'nnGPU')
  precision = class(gather(data.X(1)));
  calcMode = nnGPU('precision',precision);
  err = calcMode.netCheck(net);
  if ~isempty(err)
    error( 'nnet:train:TrainArgumentError', '%s', err );
  end
end

% If Cell of gpuArray data => Change top mode to nnGPUOp
isCellofGPUArray = ~isComposite &&~isGPUArray && ~isempty(data.X) && isa(data.X{1},'gpuArray');
if isCellofGPUArray && ~strcmp(calcMode.mode,'nnGPUOp')
  calcMode = nnGPUOp;
end

% If nnGPUOp, but data is gpuArray, change to nnGPU
if isGPUArray && strcmp(calcMode.mode,'nnGPUOp')
  calcMode = nnGPU;
end

% Fill out default subcalcs
calcMode = nncalc.defaultMode(net,calcMode);

% If Parallel mode is requested, check PCT, GCP and SPMD availability
% Fall back gracefully to single process, with displayed messages
if strcmp(calcMode.mode,'nnParallel')
  if ~nnDependency.distCompAvailable
    disp(getStringSafe(message('nnet:parallel:CannotUseParallelPool')));
    disp(getStringSafe(message('nnet:parallel:PCTLicenseNotAvailable')));
    calcMode = calcMode.hints.subcalc;
  else
    pool = gcp; % (Will auto-open pool according to PCT preferences) 
    if isempty(pool)
      disp(getStringSafe(message('nnet:parallel:CannotUseParallelPool')));
      disp(getStringSafe(message('nnet:parallel:ParallelPoolNotOpen')));
      calcMode = calcMode.hints.subcalc;
    elseif ~pool.SpmdEnabled
      disp(getStringSafe(message('nnet:parallel:CannotUseParallelPool')));
      disp(getStringSafe(message('nnet:parallel:ParallelPoolDoesNotSupportSPMD')));
      calcMode = calcMode.hints.subcalc;
    end
  end
end

% If Composite data is provided, check SPMD availability
% Error if SPMD not available, as single process cannot take Composite.
if isa(data,'Composite')
  pool = gcp;
  if ~pool.SpmdEnabled
    disp(getStringSafe(message('nnet:parallel:CannotUseParallelPool')));
    error(message('nnet:parallel:ParallelPoolDoesNotSupportSPMD'));
  end
end

% If mode nnGPU or nnGPUOp is requested, check availability
% Fall back gracefully to single process, with displayed messages
if nnstring.starts(calcMode.mode,'nnGPU')
  if ~nnDependency.distCompAvailable
    disp(getStringSafe(message('nnet:parallel:CannotUseGPU')));
    disp(getStringSafe(message('nnet:parallel:PCTLicenseNotAvailable')));
    calcMode = calcMode.hints.subcalc;
  elseif (~nnGPU.isSupported)
    disp(getStringSafe(message('nnet:parallel:CannotUseGPU')));
    disp(getStringSafe(message('nnet:parallel:GPUNotAvailable')));
    calcMode = calcMode.hints.subcalc;
  end
end

% Basic Calculation Hints
calcHints = calcMode.hints;
calcHints.isComposite = isComposite;
calcHints.isGPUArray = isGPUArray || isCellofGPUArray;
calcHints.numOutputs = net.numOutputs;
calcHints.outputSizes = nn.output_sizes(net);
if isempty(net.performFcn)
  calcHints.perfNorm = false;
  calcHints.regularization = 0;
else
  calcHints.perfWB = str2func([net.performFcn '.perfwb']);
  calcHints.dPerfWB = str2func([net.performFcn '.dperf_dwb']);
  calcHints.perfParam = net.performParam;
  calcHints.perfNorm = feval([net.performFcn,'.normalize']);
  if isfield(net.performParam,'regularization')
    calcHints.regularization = net.performParam.regularization;
  else
    calcHints.regularization = 0;
  end
end
calcHints.learnWB = nn.wb_indices(net,struct,false);
doPc = true; % TODO - Make optional


%% MATLAB Calc Mode for pre-Calc
% ==============================
matlabMode = nnMATLAB;
matlabHints = matlabMode.hints;
matlabHints = nnMATLAB.netHints(net,matlabHints);

%% NOT PARALLEL
% =============
if ~strcmp(calcMode.mode,'nnParallel')
  
  % Main Worker
  calcMode.isActiveWorker = true;
  calcMode.isMainWorker = true;
  calcMode.mainWorkerInd = 1;
  calcMode.isParallel = false;
  calcHints.isActiveWorker = true;
  
  % Qu, TSu (Q and TS unflattened)
  calcHints.Qu = data.Q;
  calcHints.TSu = data.TS;
  
  % Pre-calculate Pc, Pd and flattened time, as appropriate
  PdOk = checkPdImplemented(calcMode);
  doPd = (net.numInputDelays > 0) && net.efficiency.cacheDelayedInputs && PdOk;
  calcHints.doFlattenTime = net.efficiency.flattenTime && (net.numLayerDelays==0) && ...
    (calcHints.TSu > 1) && ((net.numInputDelays==0) || doPd);
  calcData = nncalc.preCalcData(matlabMode,matlabHints,net,data,doPc,doPd,calcHints.doFlattenTime);
  
  % Update Network
  if ~isdeployed && ~isempty(net.trainFcn)
    trainInfo = feval(net.trainFcn,'info');
    if nnstring.starts(calcMode.mode,'nnGPU') && trainInfo.usesJacobian
      trainParam = net.trainParam;
      net.trainFcn = 'trainscg';
      net.trainParam = struct(trainscg('defaultParam'));
      fields = fieldnames(trainParam);
      for i=1:numel(fields);
        f = fields{i};
        if isfield(net.trainParam,f)
          net.trainParam.(f) = trainParam.(f);
        end
      end
      disp('NOTICE: Jacobian training not supported on GPU. Training function set to TRAINSCG.');
    end
  end
  
  calcNet = net;
  calcHints = calcMode.netHints(net,calcHints);
  
  if showResources
    resourceText = mode2Text(calcMode,calcHints);
  else
    resourceText = {};
  end
  return
end

%% PARALLEL INFO: workerInd,workerModes, workerQs, workerTS, usesGPU
% ==================================================================

subMode = calcMode.hints.subcalc;
calcMode.isParallel = true;
pool = gcp;
poolSize = pool.NumWorkers;

% Case 1: Composite Data
if isComposite
  subModeIsGPU = nnstring.starts(subMode.mode,'nnGPU');
  subPrecision = subMode.hints.precision;

  % gather worker info
  spmd
    workerInfo = struct;
    if isempty(data) || (data.Q == 0)
      workerInfo.Q = 0;
      workerInfo.TS = 0;
      workerInfo.precision = '';
      workerInfo.isGPUArray = false;
      workerInfo.isCellofGPUArray = false;
      workerInfo.gpuID = '';
    elseif isa(data.X,'gpuArray')
      workerInfo.Q = data.Q;
      workerInfo.TS = data.TS;
      workerInfo.precision = classUnderlying(data.X);
      workerInfo.isGPUArray = true;
      workerInfo.isCellofGPUArray = false;
      workerInfo.gpuID = nnParallel.gpuID;
    elseif ~isempty(data.X) && isa(data.X{1},'gpuArray')
      workerInfo.Q = data.Q;
      workerInfo.TS = data.TS;
      workerInfo.precision = classUnderlying(data.X{1});
      workerInfo.isGPUArray = false;
      workerInfo.isCellofGPUArray = true;
      workerInfo.gpuID = nnParallel.gpuID;
    elseif subModeIsGPU
      workerInfo.Q = data.Q;
      workerInfo.TS = data.TS;
      workerInfo.precision = subPrecision;
      workerInfo.isGPUArray = false;
      workerInfo.isCellofGPUArray = false;
      workerInfo.gpuID = nnParallel.gpuID;
    else
      workerInfo.Q = data.Q;
      workerInfo.TS = data.TS;
      workerInfo.precision = subPrecision;
      workerInfo.isGPUArray = false;
      workerInfo.isCellofGPUArray = false;
      workerInfo.gpuID = '';
    end
  end
  workerInfo = nnParallel.composite2Cell(workerInfo);
  workerInfo = [ workerInfo{:} ];
  workerQs = [ workerInfo(:).Q ];
  activeWorkers = (workerQs > 0);
  workerInd = find(activeWorkers);
  
  if isempty(workerInd)
    workerInd = 1;
  end
  
  workerTSs = [workerInfo(:).TS];
  activeTS = workerTSs(activeWorkers);
  workerTS = max([0 activeTS]);
  if any(activeTS ~= workerTS)
    error('Cannot compute with inconsistent timesteps across workers.');
  end
  workerPrecisions = { workerInfo(:).precision };
  if numel(unique([workerPrecisions {''}])) > 2
    error('Cannot compute with inconsistent precision across workers.');
  end
  workerGPUIDs = { workerInfo(:).gpuID };
  % Any GPUs?
  usesGPU = (numel(unique([{''} workerGPUIDs])) > 1);
  % Assign sub modes
  workerModes = cell(1,poolSize);
  for i=workerInd
    if ~isempty(workerGPUIDs{i})
      % GPU Submode
      if workerInfo(i).isCellofGPUArray
        workerModes{i} = nnGPUOp('precision',workerPrecisions{i}); 
      else
        workerModes{i} = nnGPU('precision',workerPrecisions{i});
      end
    elseif subModeIsGPU
      % GPU Fallback
      workerModes{i} = subMode.hints.subcalc;
    else
      % Regular Submode
      workerModes{i} = subMode;
    end
  end

  calcHints.Qu = sum(workerQs);
  calcHints.TSu = workerTS;
  
% Case 2: MATLAB Data, subcalc GPU, onlyGPUs
elseif nnstring.starts(subMode.mode,'nnGPU') && calcMode.hints.onlyGPUs

  % gather worker info
  spmd
    gpuIDs = nnParallel.gpuID;
  end
  gpuIDs = nnParallel.composite2Cell(gpuIDs);

  [~,workerInd] = unique([{''} gpuIDs],'first');
  workerInd = workerInd(2:end)-1;
  
  % If no GPU workers fallback
  usesGPU = ~isempty(workerInd);
  if ~usesGPU
    workerInd = 1:poolSize;
    subMode = nncalc.defaultMode(net);
  end
    
  workerModes = cell(1,poolSize);
  for i=(workerInd(:)')
    workerModes{i} = subMode;
  end
  
  % Pre-process, pre-delay and flatten in aggregate
  calcHints.Qu = data.Q;
  calcHints.TSu = data.TS;
  PdOk = checkPdImplemented(calcMode);
  doPd = (net.numInputDelays > 0) && net.efficiency.cacheDelayedInputs && PdOk;
  calcHints.doFlattenTime = net.efficiency.flattenTime && (net.numLayerDelays==0) && ...
    (calcHints.TSu > 1) && ((net.numInputDelays==0) || doPd);
  data = nncalc.preCalcData(matlabMode,matlabHints,net,data,doPc,doPd,calcHints.doFlattenTime);
  calcHints.Q = data.Q;
  calcHints.TS = data.TS;

  % Load Balance
  workerQs = zeros(1,poolSize);
  workerQs(workerInd) = nnParallel.loadBalance(data.Q,numel(workerInd));
  
% Case 3: MATLAB Data, subcalc GPU, ~GPUonly
elseif nnstring.starts(subMode.mode,'nnGPU') && ~calcMode.hints.onlyGPUs

  % gather worker info
  spmd
    gpuIDs = nnParallel.gpuID;
  end
  gpuIDs = nnParallel.composite2Cell(gpuIDs);

  [~,gpuInd] = unique([{''} gpuIDs],'first');
  gpuInd = gpuInd(2:end)-1;
  usesGPU = ~isempty(gpuInd);
  workerInd = 1:poolSize;
  workerModes = cell(1,poolSize);
  fallbackMode = subMode.hints.subcalc;
  for i=(workerInd(:)')
    if ~isempty(find(i==gpuInd,1))
      workerModes{i} = subMode;
    else
      workerModes{i} = fallbackMode;
    end
  end

  % Pre-process, pre-delay and flatten in aggregate
  calcHints.Qu = data.Q;
  calcHints.TSu = data.TS;
  PdOk = checkPdImplemented(calcMode);
  doPd = (net.numInputDelays > 0) && net.efficiency.cacheDelayedInputs && PdOk;
  calcHints.doFlattenTime = net.efficiency.flattenTime && (net.numLayerDelays==0) && ...
    (calcHints.TSu > 1) && ((net.numInputDelays==0) || doPd);
  data = nncalc.preCalcData(matlabMode,matlabHints,net,data,doPc,doPd,calcHints.doFlattenTime);
  calcHints.Q = data.Q;
  calcHints.TS = data.TS;

  % Load Balance
  workerQs = zeros(1,poolSize);
  workerQs(workerInd) = nnParallel.loadBalance(data.Q,numel(workerInd));

% Case 4: MATLAB Data, subcalc non-GPU
else
  workerModes = repmat({subMode},1,poolSize);
  
  % Pre-process, pre-delay and flatten in aggregate
  calcHints.Qu = data.Q;
  calcHints.TSu = data.TS;
  PdOk = checkPdImplemented(calcMode);
  doPd = (net.numInputDelays > 0) && net.efficiency.cacheDelayedInputs && PdOk;
  calcHints.doFlattenTime = net.efficiency.flattenTime && (net.numLayerDelays==0) && ...
    (calcHints.TSu > 1) && ((net.numInputDelays==0) || doPd);
  data = nncalc.preCalcData(matlabMode,matlabHints,net,data,doPc,doPd,calcHints.doFlattenTime);
  calcHints.Q = data.Q;
  calcHints.TS = data.TS;

  % Load Balance
  workerQs = nnParallel.loadBalance(data.Q,poolSize);
  usesGPU = false;
end

% Update Network
if ~isdeployed && ~isempty(net.trainFcn)
  trainInfo = feval(net.trainFcn,'info');
  if usesGPU && trainInfo.usesJacobian
    trainParam = net.trainParam;
    net.trainFcn = 'trainscg';
    net.trainParam = struct(trainscg('defaultParam'));
    fields = fieldnames(trainParam);
    for i=1:numel(fields);
      f = fields{i};
      if isfield(net.trainParam,f)
        net.trainParam.(f) = trainParam.(f);
      end
    end
    disp('NOTICE: Jacobian training not supported on GPU. Training function set to TRAINSCG.');
  end
end

%% Setup Workers
% ==============

workerInd = find(workerQs > 0);
if isempty(workerInd)
  workerInd = 1;
end
calcHints.workerQs = workerQs;
calcHints.numSlices = numel(workerInd);
calcHints.allSliceIndices = cell(1,poolSize);
workerStops = cumsum(workerQs);
workerStarts = [1 workerStops(1:(end-1))+1];
for i=workerInd
  calcHints.allSliceIndices{i} = workerStarts(i):workerStops(i);
end

calcMode.workerInd = workerInd;
calcHints.workerInd = workerInd;
calcMode.mainWorkerInd = workerInd(1);
calcHints.mainWorkerInd = workerInd(1);

% Set up Composite calcMode, pre-calculated calcData, calcNet and calcHints
if ~isComposite
    
  % Distribute data
  calcData = Composite;
  for i=workerInd
    
    % Split Data
    qq = calcHints.allSliceIndices{i};
    datai = nncalc.split_data(data,qq);
    
    % Do not pre-calc data individually
    %calcHints.Q = data.Q;
    %calcHints.TS = data.TS;
    %calcHints.Qu = data.Q;
    %calcHints.TSu = data.TS;
    datai.doFlattenTime = false;
    
    calcData{i} = datai;
    calcHints = calcMode.netHints(net,calcHints);
  end
  workerModes = nnParallel.cell2Composite(workerModes);
  calcMode = nnParallel.copy2Composite(calcMode);
  calcNet = nnParallel.copy2Composite(net);
  calcHints = nnParallel.copy2Composite(calcHints);
  spmd
    calcMode.isMainWorker = (calcMode.mainWorkerInd == labindex);
    if ~isempty(workerModes) && any(workerInd == labindex)
      calcMode.isActiveWorker = true;
      calcHints.isActiveWorker = true;
      calcHints.subcalc = workerModes;
      calcHints.subhints = workerModes.hints;
      calcHints.subhints = calcHints.subcalc.netHints(calcNet,calcHints.subhints);
      calcHints.subhints.isGPUArray = isa(calcData.X,'gpuArray');
    else
      calcMode.isActiveWorker = false;
      calcNet = [];
      calcData = [];
      calcHints = struct;
      calcHints.isActiveWorker = false;
      calcHints.isMainWorker = false;
      calcHints.mainWorkerInd = calcMode.mainWorkerInd;
    end
    if showResources
      if calcHints.isActiveWorker
        workerResourceTexts = mode2Text(calcHints.subcalc,calcHints.subhints);
      else
        workerResourceTexts = {'Unused'};
      end
      hostIDs = nnParallel.hostID;
    end
  end
else
  
  % Do not pre-calc data in aggregate
  calcHints.doFlattenTime = false;
  calcHints.Q = calcHints.Qu;
  calcHints.TS = calcHints.TSu;
  
  % Pre-process, pre-delay and flatten individually
  calcData = data;
  workerModes = nnParallel.cell2Composite(workerModes);
  calcMode = nnParallel.copy2Composite(calcMode);
  calcNet = nnParallel.copy2Composite(net);
  calcHints = nnParallel.copy2Composite(calcHints);
  spmd
    calcMode.isMainWorker = (calcMode.mainWorkerInd == labindex);
    if ~isempty(workerModes)
      calcMode.isActiveWorker = true;
      calcHints.isActiveWorker = true;
      calcHints.isMainWorker = (calcMode.mainWorkerInd == labindex);
      calcHints.subcalc = workerModes;
      calcHints.subhints = workerModes.hints;
      calcHints.subhints = calcHints.subcalc.netHints(calcNet,calcHints.subhints);

      calcHints.subhints.Qu = data.Q;
      calcHints.subhints.TSu = data.TS;
      PdOk = checkPdImplemented(calcMode);
      doPd = (net.numInputDelays > 0) && net.efficiency.cacheDelayedInputs && PdOk;
      calcHints.subhints.flattenTime = net.efficiency.flattenTime && (net.numLayerDelays==0) && ...
        (calcHints.TSu > 1) && ((net.numInputDelays==0) || doPd);
      calcData = nncalc.preCalcData(matlabMode,matlabHints,net,calcData,doPc,doPd,calcHints.subhints.flattenTime);
      calcHints.subhints.Q = data.Q;
      calcHints.subhints.TS = data.TS;
      calcHints.subhints.isGPUArray = isa(calcData.X,'gpuArray');
    else
      calcMode.isActiveWorker = false;
      calcNet = [];
      calcData = [];
      calcHints = struct;
      calcHints.isActiveWorker = false;
      calcHints.isMainWorker = false;
      calcHints.mainWorkerInd = calcMode.mainWorkerInd;
    end
    if showResources
      if calcHints.isActiveWorker
        workerResourceTexts = mode2Text(calcHints.subcalc,calcHints.subhints);
      else
        workerResourceTexts = {'Unused'};
      end
      hostIDs = nnParallel.hostID;
    end
  end
end
if showResources
  workerTexts = nnParallel.composite2Cell(workerResourceTexts);
  hostIDs = nnParallel.composite2Cell(hostIDs);
  for i=1:numel(workerTexts)
    texti = workerTexts{i};
    texti{1} = ['Worker ' num2str(i) ' on ' hostIDs{i} ', ' texti{1}];
    workerTexts{i} = texti;
  end
  line1 = 'Parallel Workers:';
  workerText = indentText([workerTexts{:}]');
  resourceText = [{line1}; workerText];
else
  resourceText = {};
end

function flag = checkPdImplemented(calcMode)

if strcmp(calcMode.mode,'nnMex')
  flag = false;
elseif nnstring.starts(calcMode.mode,'nnGPU')
  flag = false;
elseif isfield(calcMode.hints,'subcalc')
  flag = checkPdImplemented(calcMode.hints.subcalc);
elseif isfield(calcMode.hints,'subcalcs')
  for i=1:numel(calcMode.hints.subcalcs)
    if ~checkPdImplemented(calcMode.hints.subcalcs{i})
      flag = false;
      return
    end
  end
  flag = true;
else
  flag = true;
end

function modeText = mode2Text(calcMode,calcHints)  
  
switch calcMode.mode

  case 'nn2Point'
    subText = mode2Text(calcHints.subcalc);
    line1 = ['2-Point Approximation, ' subText{1}];
    modeText = [{line1} indentText(subText(2:end))];

  case 'nn5Point'
    subText = mode2Text(calcHints.subcalc);
    line1 = ['5-Point Approximation, ' subText{1}];
    modeText = [{line1} indentText(subText(2:end))];

  case 'nn7'
    modeText = {['MATLAB on ' computer]};

  case 'nnGPU'
    gpuInfo = gpuDevice;
    modeText = {['GPU device #' num2str(gpuInfo.Index) ', ' gpuInfo.Name ', CUDA']};

  case 'nnGPUOp'
    gpuInfo = gpuDevice;
    modeText = {['GPU device #' num2str(gpuInfo.Index) ', ' gpuInfo.Name]};

  case 'nnMATLAB'
    modeText = {['MATLAB on ' computer]};

  case 'nnMemReduc'
    subText = mode2Text(calcHints.subcalc);
    line1 = ['Memory Reduction ' num2str(calcHints.reduction) ', ' subText{1}];
    modeText = [{line1} indentText(subText(2:end))];

  case 'nnMex'
    modeText = {['MEX on ' computer]};

  case 'nnNPoint'
    subText = mode2Text(calcHints.subcalc);
    line1 = ['N-Point Approximation, ' subText{1}];
    modeText = [{line1} indentText(subText(2:end))];

  case 'nnSimple'
    modeText = {['MATLAB on ' computer]};
    
  otherwise
    modeText = {calcMode.name};
end

function text = indentText(text)

for i=1:numel(text)
  text{i} = ['  ' text{i}];
end

function s = getStringSafe(m)
% Get string for message. Return identifier if no string available.
% This avoids errors on development machines w/o updatable message catalog
try
  s = getString(m);
catch
  s = m.Identifier;
end
