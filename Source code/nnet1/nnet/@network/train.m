function [net,tr,out3,out4,out5,out6]=train(net,varargin)
%TRAIN Train a neural network.
%
%  [NET,TR] = <a href="matlab:doc train">train</a>(NET,X,T) takes a network NET, input data X
%  and target data T and returns the network after training it, and a
%  a training record TR.
%
%  [NET,TR] = <a href="matlab:doc train">train</a>(NET,X) takes only input data, in cases where
%  the network's training function is unsupervised (i.e. does not require
%  target data).
%
%  [NET,TR] = <a href="matlab:doc train">train</a>(NET,X,T,Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  <a href="matlab:doc train">train</a> calls the network training function NET.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> with the
%  parameters NET.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a> to perform training.  Training functions
%  may also be called directly.
%
%  <a href="matlab:doc train">train</a> arguments can have two formats: matrices, for static
%  problems and networks with single inputs and outputs, and cell arrays
%  for multiple timesteps and networks with multiple inputs and outputs.
%
%  The matrix format is as follows:
%    X  - RxQ matrix
%    Y  - UxQ matrix.
%  Where:
%    Q  = number of samples
%    R  = number of elements in the network's input
%    U  = number of elements in the network's output
%
%  The cell array format is most general:
%    X  - NixTS cell array, each element X{i,ts} is an RixQ matrix.
%    Xi - NixID cell array, each element Xi{i,k} is an RixQ matrix.
%    Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%    Y  - NOxTS cell array, each element Y{i,ts} is a UixQ matrix.
%    Xf - NixID cell array, each element Xf{i,k} is an RixQ matrix.
%    Af - NlxLD cell array, each element Af{i,k} is an SixQ matrix.
%  Where:
%    TS = number of time steps
%    Ni = NET.<a href="matlab:doc nnproperty.net_numInputs">numInputs</a>
%    Nl = NET.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>,
%    No = NET.<a href="matlab:doc nnproperty.net_numOutputs">numOutputs</a>
%    ID = NET.<a href="matlab:doc nnproperty.net_numInputDelays">numInputDelays</a>
%    LD = NET.<a href="matlab:doc nnproperty.net_numLayerDelays">numLayerDelays</a>
%    Ri = NET.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_size">size</a>
%    Si = NET.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>
%    Ui = NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_size">size</a>
%
%  The error weights EW can be 1, indicating all targets are equally
%  important.  It can also be either a 1xQ vector defining relative sample
%  importances, a 1xTS cell array of scalar values defining relative
%  timestep importances, an Nox1 cell array of scalar values defining
%  relative network output importances, or in general an NoxTS cell array
%  of NixQ matrices (the same size as T) defining every target element's
%  relative importance.
%
%  The training record TR is a structure whose fields depend on the network
%  training function (net.NET.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a>). It may include fields such as:
%    *  Training, data division, and performance functions and parameters
%    * Data division indices for training, validation and test sets
%    * Data division masks for training validation and test sets
%    * Number of epochs (num_epochs) and the best epoch (best_epoch).
%    * A list of training state names (states).
%    * Fields for each state name recording its value throughout training
%    * Performances of the best network (best_perf, best_vperf, best_tperf)
%
%  Here a static feedforward network is created, trained on some data, then
%  simulated using SIM and network notation.
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y1 = <a href="matlab:doc sim">sim</a>(net,x)
%    y2 = net(x)
%
%  Here a dynamic NARX network is created, trained, and simulated on
%  time series data.
%
%   [X,T] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%   net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%   <a href="matlab:doc view">view</a>(net)
%   [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%   Y = net(Xs,Xi,Ai)
%
%  <strong>Training with Parallel Computing</strong>
%
%  Parallel Computing Toolbox allows Neural Network Toolbox to train
%  networks faster and on larger datasets than can fit on one PC.
%
%  (Parallel and GPU training are currently supported for backpropagation
%  training only, i.e. not Self-Organizing Maps.
%
%  Here training automatically happens across MATLAB parallel workers.
%
%    parpool
%    [X,T] = vinyl_dataset;
%    net = feedforwardnet(140,'trainscg');
%    net = <a href="matlab:doc train">train</a>(net,X,T,'UseParallel','yes');
%    Y = net(X,'UseParallel','yes');
%
%  Use Composite values to distribute the data manually, and get back
%  the results as a Composite value.  If the data is loaded as it is
%  distributed then while each piece of the dataset must fit in RAM, the
%  entire dataset is only limited by the number of workers RAM.  Use
%  the function <a href="matlab:doc configure">configure</a> to prepare a network for training
%  with parallel data.
%
%    net = feedforwardnet(140,'trainscg');
%    net = configure(net,X,T);
%    Xc = Composite;
%    Tc = Composite;
%    for i=1:numel(Xc)
%      Xc{i} = X+rand(size(X))*0.1; % (Use real data instead
%      Tc{i} = T+rand(size(T))*0.1; % instead of random data)
%    end
%    net = <a href="matlab:doc train">train</a>(net,Xc,Tc);
%    Yc = net(Xc);
%    Y = cat(2,Yc{:});
%
%  Networks can be trained using the current GPU device, if it is
%  supported by the Parallel Computing Toolbox. This is efficient for
%  large static problems or dynamic problems with many series.
%
%    net = feedforwardnet(140,'trainscg');
%    net = <a href="matlab:doc train">train</a>(net,X,T,'UseGPU','yes');
%    Y = net(X,'UseGPU','yes');
%
%  If a network is static (no delays) and has a single input and output,
%  then training can be done with data already converted to gpuArray form,
%  if the network is configured with MATLAB data first.
%
%    net = feedforwardnet(140,'trainscg');
%    net = configure(net,X,T);
%    Xgpu = gpuArray(X);
%    Tgpu = gpuArray(T);
%    net = <a href="matlab:doc train">train</a>(net,Xgpu,Tgpu);
%    Ygpu = net(Xgpu);
%    Y = gather(Ygpu);
%
%  To run in parallel, with workers associated with unique GPUs taking
%  advantage of that hardware, while the rest of the workers use CPUs:
%
%    net = feedforwardnet(140,'trainscg');
%    net = <a href="matlab:doc train">train</a>(net,X,T,'UseParallel','yes','UseGPU','yes');
%    Y = net(X,'UseParallel','yes','UseGPU','yes');
%
%  Only using workers with unique GPUs may result in higher speed, as CPU
%  workers may not keep up.
%
%    net = feedforwardnet(140,'trainscg');
%    net = <a href="matlab:doc train">train</a>(net,X,T,'UseParallel','yes','UseGPU','only');
%    Y = net(X,'UseParallel','yes','UseGPU','only');
%
%  Use the 'ShowResources' option to verify the computing resources used.
%
%    net = train(...,'ShowResources','yes');
%
%  <strong>Training Safely with Checkpoint Files</strong>
%
%  The optional parameter CheckpointFile allows you to specify a file to periodically save
%  intermediate values of the neural network and training record during training.  This protects
%  training results from power failures, computer lock ups, Ctrl-C, or any other event that
%  halts the training process before TRAIN returns normally.
%
%  CheckpointFile can be set to the empty string to disable checkpoint saves (the default value),
%  to a filename to save to the current working directory, or a file path.
%
%  The optional parameter CheckpointDelay limits how often saves happen.  It has a default
%  value of 60 which means that checkpoint saves will not happen more than once a minute.
%  Limiting the frequency of checkpoints keeps the amount of time saving checkpoints low
%  compared to the time spent in calculations, using time efficiently.  Set CheckpointDelay
%  to 0 if you want checkpoint saves to occur every epoch.
%
%  For example, here a network is trained with checkpoints saved at a rate no greater than
%  once each two minutes.
%
%    [x,t] = vinyl_dataset;
%    net = fitnet([60 30]);
%    net = train(net,x,t,'CheckpointFile','MyCheckpoint','CheckpointDelay',120);
%
%  A computer failure happens, the latest network can be recovered and used to continue
%  training from the point of failure. The checkpoint file includes a structure variable
%  'checkpoint' which includes the network, training record, filename, time and number.
%
%    [x,t] = vinyl_dataset;
%    load MyCheckpoint
%    net = checkpoint.net;
%    net = train(net,x,t,'CheckpointFile','MyCheckpoint');
%
%  Another use for this feature is to be able to stop a parallel training session (using the
%  UseParallel parameter described above) even though the Neural Network Training Tool
%  is not available during parallel training.  Set a CheckpointFile, use Ctrl-C to stop
%  training any time, then load your checkpoint file to get the network and training record.
%
%  See also INIT, REVERT, SIM, VIEW.

%  Copyright 1992-2015 The MathWorks, Inc.

% CHECK NEURAL NETWORK ARGUMENT
if ~isa(net,'network')
    error(message('nnet:train:FirstArgNotNN'));
end
net = struct(net);
if ~isfield(net,'version') || ~ischar(net.version) || ~strcmp(net.version,'7')
    net = nnupdate.net(net);
end
[~,zeroDelayLoop] = nn.layer_order(net);
if zeroDelayLoop
    error(message('nnet:NNet:ZeroDelayLoop'));
end
if isempty(net.trainFcn)
    error(message('nnet:NNet:TrainFcnUndefined'));
end
info = feval(net.trainFcn,'info');
if info.isSupervised && isempty(net.performFcn)
    error(message('nnet:NNet:SupTrainFcnNoPerformFcn'));
end
net.efficiency.flattenedTime = net.efficiency.flattenTime && (~strcmp(net.trainFcn,'trains'));

% HANDLE NNET 5.1 Backward Compatibility
if (nargin == 6) && (isstruct(varargin{5}) && isfield(varargin{5},'P'))
    net = network(net);
    [net,tr,out3,out4,out5,out6] = v51_train_arg6(net,varargin{:});
    return
elseif (nargin == 7) && ((isstruct(varargin{5}) && hasfield(varargin{5},'P')) || (isstruct(varargin{6}) && isfield(varargin{6},'P')))
    net = network(net);
    [net,tr,out3,out4,out5,out6] = v51_train_arg7(net,varargin{:});
    return
end

% PICK CALCULATION MODE

% Undocumented Testing API.
% This API may be altered or removed at any time.
% Specify calculation mode by name as last argument of train.
if ~isempty(varargin) && isstruct(varargin{end}) && isfield(varargin{end},'name')
    calcMode = nncalc.defaultMode(net,varargin{end});
    varargin(end) = [];
    [varargin,nameValuePairs] = nnet.arguments.extractNameValuePairs(varargin);
    calcMode.options = nnet.options.calc.defaults;
    [calcMode.options,err] = nnet.options.override(calcMode.options,nameValuePairs);
    if ~isempty(err)
        error( 'nnet:train:TrainArgumentError', '%s', err );
    end
    calcMode.options.showResources = 'yes';
    modeSpecified = true;

    % Documented API
    % Recommended API for customers and most testing.
    % Use optional parameter/value pairs to pick calculation mode.
else
    [varargin,nameValuePairs] = nnet.arguments.extractNameValuePairs(varargin);
    [calcMode,err,modeSpecified] = nncalc.options2Mode(net,nameValuePairs);
    if ~isempty(err)
        error( 'nnet:train:TrainArgumentError', '%s', err );
    end
end
err = calcMode.netCheck(net,calcMode.hints,false,false);
if ~isempty(err)
    error( 'nnet:train:TrainArgumentError', '%s', err );
end

% CHECK DATA ARGUMENTS

% Check that data arguments are consistently Composite or not
nargs = numel(varargin);
if nargs >= 1
    isComposite = isa(varargin{1},'Composite');
else
    isComposite = false;
end
for i=2:nargs
    if isComposite ~= isa(varargin{i},'Composite')
        error(message('nnet:train:AllCompositeOrNot'));
    end
end

% Check that data arguments are consistently gpuArray or not
if nargs >= 1
    isGPUArray = isa(varargin{1},'gpuArray');
else
    isGPUArray = false;
end
for i=2:nargs
    vi = varargin{i};
    if ~isempty(vi) && (isGPUArray ~= isa(vi,'gpuArray'))
        error(message('nnet:train:AllGPUArrayOrNot'));
    end
end

% Fill in missing data consistent with type
if isComposite
    emptyCell = Composite;
    for i=1:numel(emptyCell)
        emptyCell{i} = {};
    end
else
    emptyCell = {};
end
X = vararginOrDefault(varargin,1,emptyCell);
T = vararginOrDefault(varargin,2,emptyCell);
Xi = vararginOrDefault(varargin,3,emptyCell);
Ai = vararginOrDefault(varargin,4,emptyCell);
EW = vararginOrDefault(varargin,5,emptyCell);
if isComposite
    X = fillUndefinedCompositeWithEmptyCell(X);
    T = fillUndefinedCompositeWithEmptyCell(T);
    Xi = fillUndefinedCompositeWithEmptyCell(Xi);
    Ai = fillUndefinedCompositeWithEmptyCell(Ai);
    EW = fillUndefinedCompositeWithEmptyCell(EW);
end
calcModesSupported = feval(net.trainFcn,'supportsCalcModes');
if ~calcModesSupported
    if isComposite
        error(message('nnet:parallel:TrainingFcnDoesNotSupportComposite'));
    elseif isGPUArray
        error(message('nnet:parallel:TrainingFcnDoesNotSupportGPUArray'));
    elseif modeSpecified
        error(message('nnet:parallel:TrainingOnlySupportsDefaultCalculation'));
    end
end

if(strcmp(net.performFcn, 'msesparse'))
    msesparse.checkThatNetworkIsCompatibleWithMSESparse(net, calcMode);
end

% Setup data and network for training, including:
% - Configuration and initialization if necessary
% - Generate data division masks
enableConfigure = ~isComposite;
[net,data,tr,err] = nntraining.setup(net,net.trainFcn,X,Xi,Ai,T,EW,enableConfigure,isComposite);
if strncmp( err, 'nnet:', 5 )
    error(message(err))
end
if ~isempty(err)
    nnerr.throw('Args',err),
end
if isempty(tr)
    return; % No data, no need to train
end

% TRAIN
% Training with functions that do not support calculation modes
if ~calcModesSupported
    hints = nn7.netHints(net);
    data.Pc = nn7.pc(net,data.X,data.Xi,data.Q,data.TS,hints);
    data.Pd = nn7.pd(net,data.Pc,data.Q,data.TS,hints);
    hints = nn7.dataHints(net,data,hints);
    [net,tr] = feval(net.trainFcn,'apply',net,tr,data,calcMode.options,hints,net.trainParam);
    
else
    % Prepare calculation mode
    [calcLib,calcNet,net,resourceText] = nncalc.setup(calcMode,net,data);
    tr.trainFcn = net.trainFcn;
    tr.trainParam = net.trainParam;
    if ~isempty(resourceText)
        disp(' ')
        disp('Computing Resources:')
        nntext.disp(resourceText)
        disp(' ')
    end
    trainFcn = str2func(net.trainFcn);
    
    % Train Parallel with calculation mode support
    [net,tr] = feval(trainFcn,'apply',net,data,calcLib,calcNet,tr);
end

net = network(net);

% NNET 5.1 Compatibility
if nargout > 2
    [out3,out5,out6] = sim(net,X,Xi,Ai,T);
    out4 = gsubtract(T,out3);
end
end

function v = vararginOrDefault(argin,i,replacement)
if (i <= numel(argin))
    v = argin{i};
else
    v = replacement;
end
end

function x = fillUndefinedCompositeWithEmptyCell(x)
for i=1:numel(x)
    if ~exist(x,i)
        x{i} = {};
    end
end
end