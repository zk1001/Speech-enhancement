function [out1,out2] = trainbr(varargin)
%TRAINBR Bayesian Regularization backpropagation.
%
%  <a href="matlab:doc trainbr">trainbr</a> is a network training function that updates the weight and
%  bias values according to Levenberg-Marquardt optimization.  It
%  minimizes a combination of squared errors and weights
%  and, then determines the correct combination so as to produce a
%  network which generalizes well.  The process is called Bayesian
%  regularization.
%
%  [NET,TR] = <a href="matlab:doc trainbr">trainbr</a>(NET,X,T,Xi,Ai,EW) takes additional optional
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
%    goal                 0  Performance goal
%    mu               0.005  Marquardt adjustment parameter
%    mu_dec             0.1  Decrease factor for mu
%    mu_inc              10  Increase factor for mu
%    mu_max            1e10  Maximum value for mu
%    max_fail             0  Maximum validation failures
%    min_grad          1e-7  Minimum performance gradient
%    show                25  Epochs between displays
%    showCommandLine  false  Generate command-line output
%    showWindow        true  Show training GUI
%    time               inf  Maximum time to train in seconds
%
%  Validation stops are disabled by default (max_fail = 0) so that
%  training can continue until an optimial combination of errors and
%  weights are found.  However, some weight/bias minimization can still
%  be achieved with shorter training times if validation is enabled
%  (by setting max_fail to 6 or some other strictly positive value).
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'trainbr';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also TRAINGDM, TRAINGDA, TRAINGDX, TRAINLM, TRAINRP,
%           TRAINCGF, TRAINCGB, TRAINSCG, TRAINCGP, TRAINBFG.

% Copyright 1992-2014 The MathWorks, Inc.


%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Training Functions.

persistent INFO;
if isempty(INFO)
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
usesGradient = false;
usesJacobian = true;
usesValidation = true;
supportsCalcModes = true;
info = nnfcnTraining(mfilename,'Bayesian Regularization',8.0,...
    isSupervised,usesGradient,usesJacobian,usesValidation,supportsCalcModes,...
    [ ...
    nnetParamInfo('showWindow','Show Training Window Feedback','nntype.bool_scalar',true,...
    'Display training window during training.'), ...
    nnetParamInfo('showCommandLine','Show Command Line Feedback','nntype.bool_scalar',false,...
    'Generate command line output during training.') ...
    nnetParamInfo('show','Command Line Frequency','nntype.strict_pos_int_inf_scalar',25,...
    'Frequency to update command line.'), ...
    ...
    nnetParamInfo('epochs','Maximum Epochs','nntype.pos_scalar',1000,...
    'Maximum number of training iterations before training is stopped.') ...
    nnetParamInfo('time','Maximum Training Time','nntype.pos_inf_scalar',inf,...
    'Maximum time in seconds before training is stopped.') ...
    ...
    nnetParamInfo('goal','Performance Goal','nntype.pos_scalar',0,...
    'Performance goal.') ...
    nnetParamInfo('min_grad','Minimum Gradient','nntype.pos_scalar',1e-7,...
    'Minimum performance gradient before training is stopped.') ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.pos_int_scalar',0,...
    'Maximum number of validation checks before training is stopped.') ...
    ...
    nnetParamInfo('mu','Mu','nntype.strict_pos_scalar',0.005,...
    'Mu.'), ...
    nnetParamInfo('mu_dec','Mu Decrease Ratio','nntype.strict_pos_scalar',0.1,...
    'Ratio to decrease mu.'), ...
    nnetParamInfo('mu_inc','Mu Increase Ratio','nntype.strict_pos_scalar',10,...
    'Ratio to increase mu.'), ...
    nnetParamInfo('mu_max','Maximum mu','nntype.strict_pos_scalar',1e10,...
    'Maximum mu before training is stopped.'), ...
    ], ...
    [ ...
    nntraining.state_info('gradient','Gradient','continuous','log') ...
    nntraining.state_info('mu','Mu','continuous','log') ...
    nntraining.state_info('gamk','Num Parameters','continuous','linear') ...
    nntraining.state_info('ssX','Sum Squared Param','continuous','log') ...
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
if isempty(nnstring.first_match(net.performFcn,{'sse','mse'}))
    warning(message('nnet:train:NonSqrErrorFixed'));
    net.performFcn = 'mse';
end
if isfield(net.performParam,'regularization')
    if net.performParam.regularization ~= 0
        disp([nnlink.fcn2ulink('trainbr') ': ' nnwarning.adaptive_reg_override])
        net.performParam.regression = 0;
    end
end
end

function [archNet,tr] = train_network(archNet,rawData,calcLib,calcNet,tr)
[archNet,tr] = nnet.train.trainNetwork(archNet,rawData,calcLib,calcNet,tr,localfunctions);
end

function worker = initializeTraining(archNet,calcLib,calcNet,tr)

% Cross worker existence required
worker.WB = [];

% Initial Gradient
[worker.xsE,worker.vperf,worker.tperf,worker.je,worker.jj,...
    worker.xgradient,worker.trainN] = calcLib.perfsJEJJ(calcNet);

if calcLib.isMainWorker
    
    % Training control values
    worker.epoch = 0;
    worker.startTime = clock;
    worker.param = archNet.trainParam;
    worker.originalNet = calcNet;
    [worker.best,worker.val_fail] = nntraining.validation_start(calcNet,worker.xsE,worker.vperf);
    
    worker.WB = calcLib.getwb(calcNet);
    worker.length_X = numel(worker.WB);
    
    worker.ii = sparse(1:worker.length_X,1:worker.length_X,ones(1,worker.length_X));
    worker.mu = worker.param.mu;
    
    worker.numParameters = worker.length_X;
    worker.gamk = worker.numParameters;
    if worker.xsE == 0
        worker.beta = 1;
    else
        worker.beta = (worker.trainN - worker.gamk)/(2 * worker.xsE);
    end
    if (worker.beta <=0)
        worker.beta = 1;
    end
    worker.ssX = worker.WB' * worker.WB;
    worker.alph = worker.gamk / (2 * worker.ssX);
    worker.perf = worker.beta * worker.xsE + worker.alph * worker.ssX;
    
    % Training Record
    worker.tr = nnet.trainingRecord.start(tr,worker.param.goal,...
        {'epoch','time','perf','vperf','tperf','mu','gradient','gamk','ssX','val_fail'});
    
    % Status
    worker.status = ...
        [ ...
        nntraining.status('Epoch','iterations','linear','discrete',0,worker.param.epochs,0), ...
        nntraining.status('Time','seconds','linear','discrete',0,worker.param.time,0), ...
        nntraining.status('Performance','','log','continuous',worker.xsE,worker.param.goal,worker.xsE) ...
        nntraining.status('Gradient','','log','continuous',worker.xgradient,worker.param.min_grad,worker.xgradient) ...
        nntraining.status('Mu','','log','continuous',worker.mu,worker.param.mu_max,worker.mu) ...
        nntraining.status('Effective # Param','','linear','continuous',worker.gamk,0,worker.gamk) ...
        nntraining.status('Sum Squared Param','','log','continuous',worker.ssX,0,worker.ssX) ... ...
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
elseif (worker.xsE <= worker.param.goal)
    worker.tr.stop = message('nnet:trainingStop:PerformanceGoalMet');
    calcNet = worker.best.net;
elseif (worker.epoch == worker.param.epochs)
    worker.tr.stop = message('nnet:trainingStop:MaximumEpochReached');
    calcNet = worker.best.net;
elseif (current_time >= worker.param.time)
    worker.tr.stop = message('nnet:trainingStop:MaximumTimeElapsed');
    calcNet = worker.best.net;
elseif (worker.xgradient <= worker.param.min_grad)
    worker.tr.stop = message('nnet:trainingStop:MinimumGradientReached');
    calcNet = worker.best.net;
elseif (worker.mu >= worker.param.mu_max)
    worker.tr.stop = message('nnet:trainingStop:MaximumMuReached');
    calcNet = worker.best.net;
elseif (worker.val_fail >= worker.param.max_fail) && (worker.param.max_fail > 0)
    worker.tr.stop = message('nnet:trainingStop:ValidationStop');
    calcNet = worker.best.net;
end

% Training Record
worker.tr = nnet.trainingRecord.update(worker.tr, ...
    [worker.epoch current_time worker.xsE worker.vperf worker.tperf worker.mu ...
    worker.xgradient worker.gamk worker.ssX worker.val_fail]);
worker.statusValues = ...
    [worker.epoch,current_time,worker.xsE,worker.xgradient,worker.mu,worker.gamk,worker.ssX,worker.val_fail];
end

function [worker,calcNet] = trainingIteration(worker,calcLib,calcNet)

% Cross worker control variables
worker.muBreak = [];
worker.perfBreak = [];
worker.WB2 = [];

% Bayesian Regularization
while true
    if calcLib.isMainWorker
        worker.muBreak = (worker.mu > worker.param.mu_max);
    end
    if calcLib.broadcast(worker.muBreak)
        break;
    end
    
    if calcLib.isMainWorker
        
        [dX,flag_inv] = computeDX(worker);
        
        worker.WB2 = worker.WB + dX;
        ssX2 = worker.WB2' * worker.WB2;
    end
    
    calcNet2 = calcLib.setwb(calcNet,worker.WB2);
    xsE2 = calcLib.trainPerf(calcNet2);
    
    if calcLib.isMainWorker
        perf2 = worker.beta * xsE2 + worker.alph * ssX2;
    end
    
    if calcLib.isMainWorker
        worker.perfBreak = (perf2 < worker.perf) && all(isfinite(dX)) && flag_inv;
    end
    if calcLib.broadcast(worker.perfBreak)
        if calcLib.isMainWorker
            [worker.WB,worker.ssX,worker.perf] = deal(worker.WB2,ssX2,perf2);
        end
        calcNet = calcLib.setwb(calcNet,worker.WB2);
        if calcLib.isMainWorker
            worker.mu = worker.mu * worker.param.mu_dec;
            if (worker.mu < 1e-20)
                worker.mu = 1e-20;
            end
        end
        break
    end
    if calcLib.isMainWorker
        worker.mu = worker.mu * worker.param.mu_inc;
    end
end
[worker.xsE,worker.vperf,worker.tperf,worker.je,worker.jj,worker.xgradient] = ...
    calcLib.perfsJEJJ(calcNet);

if calcLib.isMainWorker
    if (worker.mu <= worker.param.mu_max)
        % Update regularization parameters and performance function
        warnstate = warning('off','all');
        worker.gamk = worker.numParameters - worker.alph * trace(inv(worker.beta * worker.jj + worker.ii * worker.alph));
        warning(warnstate);
        if (worker.ssX == 0)
            worker.alph = 1;
        else
            worker.alph = worker.gamk / (2 * worker.ssX);
        end
        if (worker.xsE == 0)
            worker.beta = 1;
        else
            worker.beta = (worker.trainN - worker.gamk)/( 2* worker.xsE);
        end
        worker.perf = worker.beta * worker.xsE + worker.alph * worker.ssX;
    end
    
    % Track Best Network
    [worker.best,worker.tr,worker.val_fail] = nnet.train.trackBestNetwork(...
        worker.best,worker.tr,worker.val_fail,calcNet,worker.xsE,worker.vperf,worker.epoch);
end
end

function [dX,flag_inv] = computeDX(worker)

% Check for Singular Matrix warnings
[msgstr,msgid] = lastwarn;
lastwarn('MATLAB:nothing','MATLAB:nothing') % Save lastwarn state
warnstate = warning('off','all'); % Suppress warnings

num = -(worker.beta * worker.jj + worker.ii * (worker.mu + worker.alph));
den = (worker.beta * worker.je + worker.alph * worker.WB);
dX = num \ den;

[~,msgid1] = lastwarn;
flag_inv = isequal(msgid1,'MATLAB:nothing');
if flag_inv
    lastwarn(msgstr,msgid);
end; % Restore lastwarn state
warning(warnstate); % Restore warnings
end