function [out1,out2] = traincgb(varargin)
%TRAINCGB Conjugate gradient backpropagation with Powell-Beale restarts.
%
%  <a href="matlab:doc traincgb">traincgb</a> is a network training function that updates weight and
%  bias values according to the conjugate gradient backpropagation
%  with Powell-Beale restarts.
%
%  [NET,TR] = <a href="matlab:doc traincgb">traincgb</a>(NET,X,T) takes a network NET, input data X
%  and target data T and returns the network after training it, and a
%  a training record TR.
%
%  [NET,TR] = <a href="matlab:doc traincgb">traincgb</a>(NET,X,T,Xi,Ai,EW) takes additional optional
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
%    min_grad         1e-10  Minimum performance gradient
%    max_fail             6  Maximum validation failures
%    searchFcn    'srchcha'  Name of line search routine to use
%
%  Parameters related to line search methods (not all used for all methods):
%    scal_tol         20  Divide into delta to determine tolerance for linear search.
%    alpha         0.001  Scale factor which determines sufficient reduction in perf.
%    beta            0.1  Scale factor which determines sufficiently large step size.
%    delta          0.01  Initial step size in interval location step.
%    gama            0.1  Parameter to avoid small reductions in performance. Usually set
%                            to 0.1. (See use in SRCHCHA.)
%    low_lim         0.1  Lower limit on change in step size.
%    up_lim          0.5  Upper limit on change in step size.
%    maxstep         100  Maximum step length.
%    minstep      1.0e-6  Minimum step length.
%    bmax             26  Maximum step size.
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'traincgb';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also TRAINGDM, TRAINGDA, TRAINGDX, TRAINLM, TRAINCGP,
%           TRAINCGF, TRAINCGB, TRAINSCG, TRAINOSS, TRAINBFG.

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
usesGradient = true;
usesJacobian = false;
usesValidation = true;
supportsCalcModes = true;
info = nnfcnTraining(mfilename,'Conjugate Gradient with Beale-Powell Restarts',8.0,...
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
    nnetParamInfo('min_grad','Minimum Gradient','nntype.strict_pos_scalar',1e-10,...
    'Minimum performance gradient before training is stopped.') ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.pos_int_scalar',6,...
    'Maximum number of validation checks before training is stopped.') ...
    ...
    nnetParamInfo('searchFcn','Line search function','nntype.search_fcn','srchcha',...
    'Line search function used to optimize performance each epoch.') ...
    nnetParamInfo('scale_tol','Scale Tolerance','nntype.pos_scalar',20,...
    'Scale tolerance used for line search.') ...
    ...
    nnetParamInfo('alpha','Alpha','nntype.pos_scalar',0.001,...
    'Alpha.') ...
    nnetParamInfo('beta','Beta','nntype.pos_scalar',0.1,...
    'Beta.') ...
    nnetParamInfo('delta','Delta','nntype.pos_scalar',0.01,...
    'Delta.') ...
    nnetParamInfo('gama','Gamma','nntype.pos_scalar',0.1,...
    'Gamma.') ...]) ...
    nnetParamInfo('low_lim','Lower Limit','nntype.pos_scalar',0.1,...
    'Lower limit.') ...
    nnetParamInfo('up_lim','Upper Limit','nntype.pos_scalar',0.5,...
    'Upper limit.') ...
    nnetParamInfo('max_step','Maximum Step','nntype.pos_scalar',100,...
    'Maximum step.') ...
    nnetParamInfo('min_step','Minimum Step','nntype.pos_scalar',1.0e-6,...
    'Minimum step.') ...
    nnetParamInfo('bmax','B Max','nntype.pos_scalar',26,...
    'B Max.'), ...
    ], ...
    [ ...
    nntraining.state_info('gradient','Gradient','continuous','log') ...
    nntraining.state_info('val_fail','Validation Checks','discrete','linear') ...
    nntraining.state_info('a','Step Size','continuous','log') ...
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

% Cross worker control variables
worker.searchFcn = '';
if calcLib.isMainWorker
    worker.searchFcn = archNet.trainParam.searchFcn;
end
worker.searchFcn = calcLib.broadcast(worker.searchFcn);

% Cross worker existence required
worker.WB = [];
worker.dX = [];
worker.dperf = [];
worker.delta = [];
worker.tol = [];
worker.ch_perf = [];
worker.param = [];

% Initial Gradient
[worker.perf,worker.vperf,worker.tperf,worker.gX,worker.gradient] = calcLib.perfsGrad(calcNet);

if calcLib.isMainWorker
    
    % Training control values
    worker.epoch = 0;
    worker.param = archNet.trainParam;
    worker.startTime = clock;
    worker.original_net = calcNet;
    [worker.best,worker.val_fail] = nntraining.validation_start(calcNet,worker.perf,worker.vperf);
    
    worker.gX = -worker.gX;
    worker.WB = calcLib.getwb(calcNet);
    worker.num_X = length(worker.WB);
    
    worker.delta = worker.param.delta;
    worker.tol = worker.delta / worker.param.scale_tol;
    worker.a = 1;
    
    % Training Record
    worker.tr = nnet.trainingRecord.start(tr,worker.param.goal,...
        {'epoch','time','perf','vperf','tperf','gradient','val_fail','a'});
    
    % Status
    worker.status = ...
        [ ...
        nntraining.status('Epoch','iterations','linear','discrete',0,worker.param.epochs,0), ...
        nntraining.status('Time','seconds','linear','discrete',0,worker.param.time,0), ...
        nntraining.status('Performance','','log','continuous',worker.best.perf,worker.param.goal,worker.best.perf) ...
        nntraining.status('Gradient','','log','continuous',worker.gradient,worker.param.min_grad,worker.gradient) ...
        nntraining.status('Validation Checks','','linear','discrete',0,worker.param.max_fail,0) ...
        nntraining.status('Step Size','','log','continuous',worker.param.max_step,worker.param.min_step,worker.a) ...
        ];
    
    % Initial Search Direction
    worker = initialSearchDirection(worker);
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
elseif (worker.a == 0)
    worker.tr.stop = message('nnet:trainingStop:MinimumStepSizeReached');
    worker.calcNet = worker.best.net;
end

% Training Record
worker.tr = nnet.trainingRecord.update(worker.tr,...
    [worker.epoch current_time worker.perf worker.vperf worker.tperf worker.gradient worker.val_fail worker.a]);
worker.statusValues = ...
    [worker.epoch,current_time,worker.best.perf,worker.gradient,worker.val_fail,worker.a];
end

function [worker,calcNet] = trainingIteration(worker,calcLib,calcNet)

% Minimize the performance along the search direction
[worker,retcode] = callSearchFcn(worker,calcLib,calcNet);

% Keep track of the number of function evaluations
if calcLib.isMainWorker
    worker.sum1 = worker.sum1 + retcode(1);
    worker.sum2 = worker.sum2 + retcode(2);
    worker.WB = worker.WB + worker.a * worker.dX;
end

calcNet = calcLib.setwb(calcNet,worker.WB);

% Track Best Network
[worker.perf,worker.vperf,worker.tperf] = calcLib.trainValTestPerfs(calcNet);
if calcLib.isMainWorker
    [worker.best,worker.tr,worker.val_fail] = nnet.train.trackBestNetwork(...
        worker.best,worker.tr,worker.val_fail,calcNet,worker.perf,worker.vperf,worker.epoch);
end

% Next Search Direction
if calcLib.isMainWorker
    worker = updateSearchDirection(worker);
end
end

function worker = initialSearchDirection(worker)

% Performance
worker.perf_old = worker.perf;
worker.ch_perf = worker.perf;
worker.sum1 = 0;
worker.sum2 = 0;

% Initial gradient and norm of gradient
worker.norm_sqr = worker.gX' * worker.gX;
worker.gradient = sqrt(worker.norm_sqr);
worker.dX_old = -worker.gX;
worker.gX_old = worker.gX;
worker.dgX_t = zeros(size(worker.gX));
worker.dX_t = worker.dgX_t;
worker.dX_gXt = 1;

% Initial search direction and initial slope
if worker.gradient == 0,
    worker.dX = -worker.gX;
else
    worker.dX = -worker.gX / worker.gradient;
end
worker.dperf = worker.gX' * worker.dX;

% Initialize restart location
worker.t = 1;
end

function worker = updateSearchDirection(worker)

% Calculate change in performance and norm of gradient
worker.normnew_sqr = worker.gX' * worker.gX;
worker.gradient = sqrt(worker.normnew_sqr);
worker.ch_perf = worker.perf - worker.perf_old;

% Check for restart
if (abs(worker.gX_old' * worker.gX) >= 0.2*worker.normnew_sqr) || ...
        ((worker.epoch-worker.t) >= worker.num_X)
    worker.t = worker.epoch - 1;
    worker.dgX_t = worker.gX - worker.gX_old;
    worker.dX_t = worker.dX_old;
    worker.dX_gXt = worker.dX_t' * worker.dgX_t;
end

% Calculate search direction modification parameters
if (worker.epoch == worker.t + 1)
    worker.Z2 = 0;
else
    if (worker.dX_gXt == 0),
        worker.Z2 = 0;
    else
        worker.Z2 = worker.gX' * worker.dgX_t / worker.dX_gXt;
    end
end

worker.dgX = worker.gX - worker.gX_old;
worker.denom = worker.dX_old' * worker.dgX;
if (worker.denom == 0)
    worker.Z1 = 0;
else
    worker.Z1 = worker.gX' * worker.dgX / (worker.dX_old' * worker.dgX);
end

% Calculate new search direction
worker.dX = -worker.gX + worker.dX_old * worker.Z1 + worker.dX_t * worker.Z2;

% Save new directions and norm of gradient
%dgX = dX - dX_old;
worker.dX_old = worker.dX;
worker.gX_old = worker.gX;
%norm_sqr = normnew_sqr;
worker.perf_old = worker.perf;

% Normalize search direction
worker.norm_dX = norm(worker.dX);
if worker.norm_dX~=0
    worker.dX = worker.dX / worker.norm_dX;
end;

% Check for a descent direction
worker.dperf = worker.gX' * worker.dX;
if (worker.dperf >= -0.001 * worker.gradient)
    if (worker.gradient == 0)
        worker.dX = -worker.gX;
    else
        worker.dX = -worker.gX / worker.gradient;
    end
    worker.dX_old = -worker.gX;
    worker.t = worker.epoch;
    worker.dgX_t = zeros(size(worker.gX));
    worker.dX_t = worker.dgX_t;
    worker.dX_gXt = 1;
    worker.dperf = worker.gX' * worker.dX;
end
end

function [worker,retcode] = callSearchFcn(worker,calcLib,calcNet)
[worker.a,worker.gX,worker.perf,retcode,worker.delta,worker.tol] = ...
    feval(worker.searchFcn,calcLib,calcNet,worker.dX,worker.gX,...
    worker.perf,worker.dperf,worker.delta,worker.tol,worker.ch_perf,worker.param);
end
