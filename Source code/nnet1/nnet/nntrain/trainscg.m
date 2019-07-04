function [out1,out2] = trainscg(varargin)
%TRAINSCG Scaled conjugate gradient backpropagation.
%
%  <a href="matlab:doc trainscg">trainscg</a> is a network training function that updates weight and
%  bias values according to the scaled conjugate gradient method.
%
%  [NET,TR] = <a href="matlab:doc trainscg">trainscg</a>(NET,X,T) takes a network NET, input data X
%  and target data T and returns the network after training it, and a
%  a training record TR.
%
%  [NET,TR] = <a href="matlab:doc trainscg">trainscg</a>(NET,X,T,Xi,Ai,EW) takes additional optional
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
%    time               inf  Maximum time to train in seconds
%    min_grad          1e-6  Minimum performance gradient
%    max_fail             6  Maximum validation failures
%    sigma           5.0e-5  Determines change in weight for second derivative approximation.
%    lambda          5.0e-7  Parameter for regulating the indefiniteness of the Hessian.
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'trainscg';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also TRAINGDM, TRAINGDA, TRAINGDX, TRAINLM, TRAINRP,
%           TRAINCGF, TRAINCGB, TRAINBFG, TRAINCGP, TRAINOSS.

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

function info = get_info()
isSupervised = true;
usesGradient = true;
usesJacobian = false;
usesValidation = true;
supportsCalcModes = true;
info = nnfcnTraining(mfilename,'Scaled Conjugate Gradient',8.0,...
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
    nnetParamInfo('min_grad','Minimum Gradient','nntype.pos_scalar',1e-6,...
    'Minimum performance gradient before training is stopped.') ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.pos_int_scalar',6,...
    'Maximum number of validation checks before training is stopped.') ...
    ...
    nnetParamInfo('sigma','Sigma','nntype.pos_scalar',5.0e-5,...
    'Determines change in weight for second derivative approximation.') ...
    nnetParamInfo('lambda','Lambda','nntype.pos_scalar',5.0e-7,...
    'Parameter for regulating the indefiniteness of the Hessian.') ...
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
    worker.lengthWB = length(worker.WB);
    
    worker.success = 1;
    worker.lambdab = 0;
    worker.lambdak = worker.param.lambda;
    
    % Initial search direction and norm
    worker.dWB = worker.gWB;
    worker.nrmsqr_dWB = worker.dWB' * worker.dWB;
    worker.norm_dWB = sqrt(worker.nrmsqr_dWB);
    
    % Training Record
    worker.tr = nnet.trainingRecord.start(tr,worker.param.goal,...
        {'epoch','time','perf','vperf','tperf','gradient','val_fail'});
    
    % Status
    worker.status = ...
        [ ...
        nntraining.status('Epoch','iterations','linear','discrete',0,worker.param.epochs,0), ...
        nntraining.status('Time','seconds','linear','discrete',0,worker.param.time,0), ...
        nntraining.status('Performance','','log','continuous',worker.best.perf,worker.param.goal,worker.best.perf) ...
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
worker.tr = nnet.trainingRecord.update(worker.tr,...
    [worker.epoch current_time worker.perf worker.vperf worker.tperf worker.gradient worker.val_fail]);
worker.statusValues = ...
    [worker.epoch,current_time,worker.best.perf,worker.gradient,worker.val_fail];
end

function [worker,calcNet] = trainingIteration(worker,calcLib,calcNet)

% Cross worker control variables
success1 = [];

% Cross worker existence required
WB_temp = [];

% If success is true, calculate second order information
if calcLib.isMainWorker,
    success1 = (worker.success == 1);
end
if calcLib.broadcast(success1)
    if calcLib.isMainWorker
        sigmak = worker.param.sigma / worker.norm_dWB;
        WB_temp = worker.WB + sigmak * worker.dWB;
    end
    net_temp = calcLib.setwb(calcNet,WB_temp);
    gWB_temp = calcLib.grad(net_temp);
    if calcLib.isMainWorker
        sk = (worker.gWB - gWB_temp)/sigmak;
        worker.deltak = worker.dWB' * sk;
    end
end

if calcLib.isMainWorker
    % Scale deltak
    worker.deltak = worker.deltak + (worker.lambdak - worker.lambdab) * worker.nrmsqr_dWB;
    
    % IF deltak <= 0 then make the Hessian matrix positive definite
    if (worker.deltak <= 0)
        lambdab = 2*(worker.lambdak - worker.deltak / worker.nrmsqr_dWB);
        worker.deltak = -worker.deltak + worker.lambdak * worker.nrmsqr_dWB;
        worker.lambdak = lambdab;
    end
    
    % Calculate step
    muk = worker.dWB' * worker.gWB;
    alphak = muk / worker.deltak;
    
    % Calculate the comparison parameter
    WB_temp = worker.WB + alphak * worker.dWB;
end

net_temp = calcLib.setwb(calcNet,WB_temp);
[perf_temp,vperf2,tperf2,gWB_temp] = calcLib.perfsGrad(net_temp);

if calcLib.isMainWorker
    difk = 2 * worker.deltak * (worker.perf - perf_temp)/(muk^2);
    
    % If difk >= 0 then a successful reduction in error can be made
    if (difk >= 0)
        gX_old = worker.gWB;
        [calcNet,worker.WB,worker.perf,worker.vperf,worker.tperf,worker.gWB] = ...
            deal(net_temp,WB_temp,perf_temp,vperf2,tperf2,gWB_temp);
        worker.gradient = sqrt(worker.gWB' * worker.gWB);
        worker.lambdab = 0;
        worker.success = 1;
        
        % Restart the algorithm the first and every lengthWB iterations
        if rem(worker.epoch,worker.lengthWB)==1
            worker.dWB = worker.gWB;
        else
            betak = (worker.gWB' * worker.gWB - worker.gWB' * gX_old)/muk;
            worker.dWB = worker.gWB + betak * worker.dWB;
        end
        worker.nrmsqr_dWB = worker.dWB' * worker.dWB;
        worker.norm_dWB = sqrt(worker.nrmsqr_dWB);
        % If difk >= 0.75, then reduce the scale parameter
        if (difk >= 0.75),
            worker.lambdak = 0.25 * worker.lambdak;
        end
    else
        worker.lambdab = worker.lambdak;
        worker.success = 0;
    end
    
    % If difk < 0.25, then increase the scale parameter
    if (difk < 0.25) && worker.nrmsqr_dWB~=0,
        worker.lambdak = worker.lambdak + worker.deltak*(1 - difk)/worker.nrmsqr_dWB;
    end
    
    % Track Best Network
    [worker.best,worker.tr,worker.val_fail] = nnet.train.trackBestNetwork(...
        worker.best,worker.tr,worker.val_fail,calcNet,worker.perf,worker.vperf,worker.epoch);
end
end
