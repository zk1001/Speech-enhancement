function [out1,out2] = trainbfg(varargin)
%TRAINBFG BFGS quasi-Newton backpropagation.
%
%  <a href="matlab:doc trainbfg">trainbfg</a> is a network training function that updates weight and
%  bias values according to the BFGS quasi-Newton method.
%
%  <a href="matlab:doc trainbfg">trainbfg</a> trains a network with weight and bias learning rules
%  with batch updates. The weights and biases are updated at the end of
%  an entire pass through the input data.
%
%  [NET,TR] = <a href="matlab:doc trainbfg">trainbfg</a>(NET,X,T,Xi,Ai,EW) takes additional optional
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
%    searchFcn    'srchbac'  Name of line search routine to use
%
%  Parameters related to line search methods (not all used for all methods):
%    scal_tol         20  Divide into delta to determine tolerance for linear search.
%    alpha         0.001  Scale factor which determines sufficient reduction in perf.
%    beta            0.1  Scale factor which determines sufficiently large step size.
%    delta          0.01  Initial step size in interval location step.
%    gama            0.1  Parameter to avoid small reductions in performance. Usually set
%                         to 0.1. (See use in SRCH_CHA.)
%    low_lim         0.1  Lower limit on change in step size.
%    up_lim          0.5  Upper limit on change in step size.
%    maxstep         100  Maximum step length.
%    minstep      1.0e-6  Minimum step length.
%    bmax             26  Maximum step size.
%    batch_frag        0  In case of multiple batches they are considered independent.
%                         Any non zero value implies a fragmented batch, so final layers
%                         conditions of a previous trained epoch are used as initial
%                         conditions for next epoch.
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'trainbfg';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also TRAINGDM, TRAINGDA, TRAINGDX, TRAINLM, TRAINRP,
%           TRAINCGF, TRAINCGB, TRAINSCG, TRAINCGP, TRAINOSS.

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
info = nnfcnTraining(mfilename,'BFGS Quasi-Newton',8.0,...
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
    nnetParamInfo('min_grad','Minimum Gradient','nntype.pos_scalar',1e-6,...
    'Minimum performance gradient before training is stopped.') ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.pos_int_scalar',6,...
    'Maximum number of validation checks before training is stopped.') ...
    ...
    nnetParamInfo('searchFcn','Line search function','nntype.search_fcn','srchbac',...
    'Line search function used to optimize performance each epoch.') ...
    nnetParamInfo('scale_tol','Scale Tolerance','nntype.strict_pos_scalar',20,...
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
    'B Max.') ...
    nnetParamInfo('batch_frag','Batch Frag','nntype.pos_scalar',0,...
    'Batch Frag.')], ...
    [ ...
    nntraining.state_info('gradient','Gradient','continuous','log') ...
    nntraining.state_info('val_fail','Validation Checks','discrete','linear') ...
    nntraining.state_info('resets','Resets','discrete','linear') ...
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
worker.dWB = [];
worker.dperf = [];
worker.delta = [];
worker.tol = [];
worker.ch_perf = [];
worker.param = [];

% Initial Gradient
[worker.perf,worker.vperf,worker.tperf,worker.gWB,worker.gradient] = calcLib.perfsGrad(calcNet);

if calcLib.isMainWorker
    
    % Training control values
    worker.epoch = 0;
    worker.param = archNet.trainParam;
    worker.startTime = clock;
    worker.original_net = calcNet;
    [worker.best,worker.val_fail] = nntraining.validation_start(calcNet,worker.perf,worker.vperf);
    
    worker.gWB = -worker.gWB;
    worker.WB = calcLib.getwb(calcNet);
    worker.num_WB = length(worker.WB);
    
    worker.delta = worker.param.delta;
    worker.tol = worker.delta / worker.param.scale_tol;
    worker.a = 0;
    worker.cons_a0 = 0;
    
    worker.ii = speye(worker.num_WB);
    
    % Training Record
    worker.tr = nnet.trainingRecord.start(tr,worker.param.goal,...
        {'epoch','time','perf','vperf','tperf','gradient','val_fail','dperf','tol','delta','a','resets'});
    
    % Status
    worker.status = ...
        [ ...
        nntraining.status('Epoch','iterations','linear','discrete',0,worker.param.epochs,0), ...
        nntraining.status('Time','seconds','linear','discrete',0,worker.param.time,0), ...
        nntraining.status('Performance','','log','continuous',worker.best.perf,worker.param.goal,worker.best.perf) ...
        nntraining.status('Gradient','','log','continuous',worker.gradient,worker.param.min_grad,worker.gradient) ...
        nntraining.status('Validation Checks','','linear','discrete',0,worker.param.max_fail,0) ...
        nntraining.status('Step Size','','log','continuous',worker.param.max_step,worker.param.min_step,worker.a) ...
        nntraining.status('Resets','','log','continuous',0,4,0) ...
        ];
    
    % Initial Search Direction
    worker = updateSearchDirection(worker);
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
elseif any(~isfinite(worker.dWB))
    worker.tr.stop = message('nnet:trainingStop:PrecisionProblemsInMatrixInversions');
    calcNet = worker.best.net;
elseif (worker.cons_a0 >= 4)
    worker.tr.stop = message('nnet:trainingStop:LineSearchProducedNoMinimum');
    calcNet = worker.best.net;
end

% Training Record
worker.tr = nnet.trainingRecord.update(worker.tr,...
    [worker.epoch current_time worker.perf worker.vperf worker.tperf worker.gradient worker.val_fail ...
    worker.dperf worker.tol worker.delta worker.a worker.cons_a0]);
worker.statusValues = ...
    [worker.epoch,current_time,worker.best.perf,worker.gradient,worker.val_fail,worker.cons_a0];
end

function [worker,calcNet] = trainingIteration(worker,calcLib,calcNet)

% Cross worker control variables
ifFlag = [];

% Minimize the performance along the search direction
% We use previous delta for next line search
[worker.a,worker.gWB,worker.perf,retcode,worker.delta,worker.tol] = ...
    feval(worker.searchFcn,calcLib,calcNet,worker.dWB,worker.gWB,worker.perf,...
    worker.dperf,worker.delta,worker.tol,worker.ch_perf,worker.param);

% Temporal Q movement. ****
if calcLib.isMainWorker
    % Keep track of the number of function evaluations
    worker.sum1 = worker.sum1 + retcode(1);
    worker.sum2 = worker.sum2 + retcode(2);
    worker.WB_step = worker.a * worker.dWB;
    worker.WB = worker.WB + worker.WB_step;
end

calcNet = calcLib.setwb(calcNet,worker.WB);

% Gradient and Validation
if calcLib.isMainWorker
    ifFlag = (worker.a <= worker.tol) || worker.param.batch_frag; 
end
if calcLib.broadcast(ifFlag)
    [worker.perf,worker.vperf,worker.tperf,worker.gWB,worker.gradient] = calcLib.perfsGrad(calcNet);
    if calcLib.isMainWorker
        worker.gWB = -worker.gWB;
    end
else
    [worker.perf,worker.vperf,worker.tperf] = calcLib.trainValTestPerfs(calcNet);
end
if calcLib.isMainWorker
    [worker.best,worker.tr,worker.val_fail] = nnet.train.trackBestNetwork(...
        worker.best,worker.tr,worker.val_fail,calcNet,worker.perf,worker.vperf,worker.epoch);
end

% Next Search Direction
if calcLib.isMainWorker
    worker = updateSearchDirection(worker);
end
end

function worker = updateSearchDirection(worker)

if (worker.a <= worker.tol)
    % First and reset search iteration
    worker.perf_old = worker.perf;
    worker.ch_perf = worker.perf;
    worker.sum1 = 0;
    worker.sum2 = 0;
    
    % Initial gradient and norm of gradient
    worker.gWB_old = worker.gWB;
    
    % Initial search direction and initial slope
    worker.H = worker.ii;
    worker.dWB = -worker.gWB;
    worker.dperf = worker.gWB' * worker.dWB;
else
    % After first search iteration
    % Calculate change in gradient
    worker.dgWB = worker.gWB - worker.gWB_old;
    
    % Calculate change in performance and save old performance
    worker.ch_perf = worker.perf - worker.perf_old;
    worker.perf_old = worker.perf;
    
    % Calculate new Hessian approximation
    % If H is rank defficient, use previous H matrix.
    worker.H_ant = worker.H;
    den1 = worker.gWB_old' * worker.dWB;
    den2 = worker.dgWB' * worker.WB_step;
    if (den1 ~= 0)
        worker.H = worker.H + worker.gWB_old * worker.gWB_old'/den1;
    end
    if (den2 ~= 0)
        worker.H = worker.H + worker.dgWB * worker.dgWB' / den2;
    end
    if any(isnan(worker.H(:))) || (rank(worker.H) ~= worker.num_WB)
        worker.H = worker.H_ant;
    end
    
    % Calculate new search direction
    worker.dWB = -worker.H \ worker.gWB;
    
    % Check for a descent direction
    worker.dperf = worker.gWB' * worker.dWB;
    if worker.dperf > 0
        worker.H = worker.ii;
        worker.dWB = -worker.gWB;
        worker.dperf = worker.gWB' * worker.dWB;
    end
    
    % Save old norm of gradient
    worker.gradient = sqrt(worker.gWB' * worker.gWB);
    worker.gWB_old = worker.gWB;
end

worker.cons_a0 = (worker.cons_a0 + 1) * ((worker.epoch > 1) && (worker.a == 0));
end
