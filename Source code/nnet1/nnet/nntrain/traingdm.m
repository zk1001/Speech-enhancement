function [out1,out2] = traingdm(varargin)
%TRAINGDM Gradient descent with momentum.
%
%  <a href="matlab:doc traingdm">traingdm</a> is a network training function that updates weight and
%  bias values according to gradient descent with momentum.
%
%  [NET,TR] = <a href="matlab:doc traingdm">traingdm</a>(NET,X,T) takes a network NET, input data X
%  and target data T and returns the network after training it, and a
%  a training record TR.
%
%  [NET,TR] = <a href="matlab:doc traingdm">traingdm</a>(NET,X,T,Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  Training occurs according to training parameters, with default values.
%  Any or all of these can be overridden with parameter name/value argument
%  pairs appended to the input argument list, or by appending a structure
%  argument with fields having one or more of these names.
%    epochs            1000  Maximum number of epochs to train
%    show                25  Epochs between displays
%    showCommandLine  false  Generate command-line output
%    showWindow        true  Show training GUI
%    goal                 0  Performance goal
%    lr                0.01  Learning rate
%    max_fail             6  Maximum validation failures
%    mc                 0.9  Momentum constant
%    min_grad          1e-5  Minimum performance gradient
%    time       inf  Maximum time to train in seconds
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'traingdm';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also TRAINGD, TRAINGDA, TRAINGDX, TRAINLM.

% Copyright 1992-2014 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Training Functions.

persistent INFO;
if isempty(INFO),
    INFO = get_info;
end
nnassert.minargs(nargin,1);
in1 = varargin{1};
if ischar(in1)
    switch (in1)
        case 'info'
            out1 = INFO;
        case 'apply'
            [out1,out2] = train_network(varargin{2:end});
        case 'formatNet'
            out1 = formatNet(varargin{2});
        case 'check_param'
            param = varargin{2};
            err = nntest.param(INFO.parameters,param);
            if isempty(err)
                err = check_param(param);
            end
            if nargout > 0
                out1 = err;
            elseif ~isempty(err)
                nnerr.throw('Type',err);
            end
        otherwise,
            try
                out1 = eval(['INFO.' in1]);
            catch me, nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
            end
    end
else
    net = varargin{1};
    oldTrainFcn = net.trainFcn;
    oldTrainParam = net.trainParam;
    if ~strcmp(net.trainFcn,mfilename)
        net.trainFcn = mfilename;
        net.trainParam = INFO.defaultParam;
    end
    [out1,out2] = train(net,varargin{2:end});
    net.trainFcn = oldTrainFcn;
    net.trainParam = oldTrainParam;
end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
isSupervised = true;
usesGradient = true;
usesJacobian = false;
usesValidation = true;
supportsCalcModes = true;
info = nnfcnTraining(mfilename,'Gradient Descent with Momentum',8.0,...
    isSupervised,usesGradient,usesJacobian,usesValidation,supportsCalcModes,...
    [ ...
    nnetParamInfo('showWindow','Show Training Window Feedback','nntype.bool_scalar',true,...
    'Display training window during training.'), ...
    nnetParamInfo('showCommandLine','Show Command Line Feedback','nntype.bool_scalar',false,...
    'Generate command line output during training.') ...
    nnetParamInfo('show','Command Line Frequency','nntype.strict_pos_int_inf_scalar',25,...
    'Frequency to update command line.'), ...
    ...
    nnetParamInfo('epochs','Maximum Epochs','nntype.pos_int_scalar',1000,...
    'Maximum number of training iterations before training is stopped.') ...
    nnetParamInfo('time','Maximum Training Time','nntype.pos_inf_scalar',inf,...
    'Maximum time in seconds before training is stopped.') ...
    ...
    nnetParamInfo('goal','Performance Goal','nntype.pos_scalar',0,...
    'Performance goal.') ...
    nnetParamInfo('min_grad','Minimum Gradient','nntype.pos_scalar',1e-5,...
    'Minimum performance gradient before training is stopped.') ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.pos_int_scalar',6,...
    'Maximum number of validation checks before training is stopped.') ...
    ...
    nnetParamInfo('lr','Learning Rate','nntype.pos_scalar',0.01,...
    'Learning rate.') ...
    nnetParamInfo('mc','Momentum Constant','nntype.real_0_to_1',0.9,...
    'Momentum constant.') ...
    ], ...
    [ ...
    nntraining.state_info('gradient','Gradient','continuous','log') ...
    nntraining.state_info('val_fail','Validation Checks','discrete','linear') ...
    ]);
end

function err = check_param(param)
err = '';
end

function net = formatNet(net)
if isempty(net.performFcn)
    warning(message('nnet:train:EmptyPerformanceFixed'));
    net.performFcn = 'mse';
end
end

function [archNet,tr] = train_network(archNet,rawData,calcLib,calcNet,tr)
[archNet,tr] = nnet.train.trainNetwork(archNet,rawData,calcLib,calcNet,tr,localfunctions);
end

function worker = initializeTraining(archNet,calcLib,calcNet,tr)

% Cross worker existence required
worker.WB = [];

% Initial Gradient
[worker.perf,worker.vperf,worker.tperf,worker.gWB,worker.gradient] = calcLib.perfsGrad(calcNet);

if calcLib.isMainWorker
    
    % Training control values
    worker.epoch = 0;
    worker.startTime = clock;
    worker.param = archNet.trainParam;
    worker.originalNet = calcNet;
    [worker.best,worker.val_fail] = nntraining.validation_start(calcNet,worker.perf,worker.vperf);
    
    worker.WB = calcLib.getwb(calcNet);
    worker.dWB = worker.param.lr * worker.gWB;
    
    % Training Record
    worker.tr = nnet.trainingRecord.start(tr,worker.param.goal,...
        {'epoch','time','perf','vperf','tperf','gradient','val_fail'});
    
    % Status
    worker.status = ...
        [ ...
        nntraining.status('Epoch','iterations','linear','discrete',0,worker.param.epochs,0), ...
        nntraining.status('Time','seconds','linear','discrete',0,worker.param.time,0), ...
        nntraining.status('Performance','','log','continuous',worker.perf,worker.param.goal,worker.perf) ...
        nntraining.status('Gradient','','log','continuous',worker.gradient,worker.param.min_grad,worker.gradient) ...
        nntraining.status('Validation Checks','','linear','discrete',0,worker.param.max_fail,0) ...
        ];
end
end

function [worker,calcNet] = updateTrainingState(worker,calcNet)

% Stopping Criteria
current_time = etime(clock,worker.startTime);
[userStop,userCancel] =  nntraintool('check');
if userStop
    worker.tr.stop = message('nnet:trainingStop:UserStop');
    calcNet = worker.best.net;
elseif userCancel
    worker.tr.stop = message('nnet:trainingStop:UserCancel');
    calcNet = worker.originalNet;
elseif (worker.perf <= worker.param.goal)
    worker.tr.stop = message('nnet:trainingStop:PerformanceGoalMet');
    calcNet = worker.best.net;
elseif (worker.epoch == worker.param.epochs)
    worker.tr.stop = message('nnet:trainingStop:MaximumEpochReached');
    calcNet = worker.best.net;
elseif (current_time >= worker.param.time)
    worker.tr.stop = message('nnet:trainingStop:MaximumTimeElapsed');
    calcNet = worker.best.net;
elseif (worker.gradient <= worker.param.min_grad)
    worker.tr.stop = message('nnet:trainingStop:MinimumGradientReached');
    calcNet = worker.best.net;
elseif (worker.val_fail >= worker.param.max_fail)
    worker.tr.stop = message('nnet:trainingStop:ValidationStop');
    calcNet = worker.best.net;
end

% Training Record
worker.tr = nnet.trainingRecord.update(worker.tr, ...
    [worker.epoch current_time worker.perf worker.vperf worker.tperf worker.gradient worker.val_fail]);
worker.statusValues = ...
    [worker.epoch,current_time,worker.best.perf,worker.gradient,worker.val_fail];
end

function [worker,calcNet] = trainingIteration(worker,calcLib,calcNet)

% Gradient Descent with Momentum
if calcLib.isMainWorker
    worker.dWB = worker.param.mc * worker.dWB + (1-worker.param.mc) * worker.param.lr * worker.gWB;
    worker.WB = worker.WB + worker.dWB;
end
calcNet = calcLib.setwb(calcNet,worker.WB);
[worker.perf,worker.vperf,worker.tperf,worker.gWB,worker.gradient] = calcLib.perfsGrad(calcNet);

% Track Best Network
if calcLib.isMainWorker
    [worker.best,worker.tr,worker.val_fail] = nnet.train.trackBestNetwork(...
        worker.best,worker.tr,worker.val_fail,calcNet,worker.perf,worker.vperf,worker.epoch);
end
end



