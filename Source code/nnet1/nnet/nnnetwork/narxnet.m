function out1 = narxnet(varargin)
%NARXNET Nonlinear auto-associative time-series network with external input.
%
%  For an introduction use the Neural Time Series app <a href="matlab: doc ntstool">ntstool</a>.
%  Click <a href="matlab:ntstool">here</a> to launch it.
%
%  Nonlinear autoregressive networks with an external (exogenous) input,
%  can learn to predict a time series Y given past values of Y and another
%  time series X (the external/exogenous) input.
%
%  <a href="matlab:doc narxnet">narxnet</a>(inputDelays,feedbackDelays,hiddenSizes,feedbackMode,trainFcn)
%  takes row vectors of input delays, output-to-input feedback delays, a
%  row vector of N hidden layer sizes, an 'open' or 'closed' feedback mode
%  and a backpropagation training function, and returns a NARX network.
%
%  Input, output and output layers sizes are set to 0.  These sizes will
%  automatically be configured to match particular data by <a href="matlab:doc train">train</a>. Or the
%  user can manually configure inputs and outputs with <a href="matlab:doc configure">configure</a>.
%
%  Defaults are used if <a href="matlab:doc narxnet">narxnet</a> is called with fewer arguments.
%  The default arguments are (1:2,1:2,10,'open','<a href="matlab:doc trainlm">trainlm</a>').
%
%  Here a NARX network is designed. The NARX network has a standard input
%  and an open loop feedback output to an associated feedback input.
%
%    [x,t] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%    net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%    [X,Xi,Ai,T] = <a href="matlab:doc preparets">preparets</a>(net,x,{},t);
%    net = <a href="matlab:doc train">train</a>(net,X,T,Xi,Ai);
%    <a href="matlab:doc view">view</a>(net)
%    Y = net(X,Xi,Ai)
%    perf = <a href="matlab:doc perform">perform</a>(net,Y,T)
%
%  Closed-loop Form
%
%  Once designed the dynamic network can be converted to closed loop with
%  <a href="matlab:doc closeloop">closeloop</a> and simulated.
%
%    netc = <a href="matlab:doc closeloop">closeloop</a>(net);
%    <a href="matlab:doc view">view</a>(netc)
%    [Xc,Xic,Aic,Tc] = <a href="matlab:doc preparets">preparets</a>(netc,x,{},t);
%    Yc = netc(Xc,Xic,Aic);
%
%  The function <a href="matlab:doc openloop">closeloop</a> reversed this transform.
%
%  Step-Ahead Form
%
%  The open-loop neural network is by default in model form, which means it outputs
%  values at the same time as the real system would.  Note that in the network diagram
%  the minimum delay between inputs and outputs is one.  This delay can be eliminated
%  if we would like predictions of the next output to be returned a timestep ahead
%  of the actual system being modelled.
%
%    nets = removedelay(net);
%    view(net)
%    [Xs,Xis,Ais,Ts] = preparets(nets,x,{},t);
%    Ys = nets(Xs,Xis,Ais);
%
%  The function <a href="matlab:doc adddelay">adddelay</a> reversed this transform.
%
%  Multistep Prediction
%
%  Sometimes it is useful to simulate a network in open-loop form for as long as there
%  is known output data T, and then switch to closed-loop form to perform multistep
%  prediction while providing only the external input.
%
%  Here we use the training data to demonstrate this technique.  It is broken up
%  into a segment where we will provide the known target/outputs and a second
%  segment where only external inputs are known for 5 timesteps.
%
%    numTimesteps = size(x,2);\n" +
%    knownOutputTimesteps = 1:(numTimesteps-5);\n" +
%    predictOutputTimesteps = (numTimesteps-4:):numTimesteps;\n" +
%    x1 = x(1,knownOutputTimesteps);
%    t1 = t(1,knownOutputTimesteps);
%    x2 = x(1,predictOutputTimesteps);
%
%  The open-loop network is simulated on the first segment, then the network and
%  its current delay states are converted to closed-loop form to simulate on the
%  second time segment.
%
%    [Xo,Xio,Aio,To] = preparets(net,x1,{},t1);
%    [Y1,Xfo,Afo] = net(Xo,Xio,Aio);
%    [netc,Xic,Aic] = closeloop(net,Xfo,Afo);
%    [Y2,Xfc,Afc] = netc(x2,Xic,Aic);
%
%  Alternate predictions can be made for different values of X2, or further
%  predictions can be made by continuing simulation with Xfc and Afc.
%
%  Simulink Diagram
%
%  A Simulink can be produced for any neural networks using the function <a href="matlab:doc gensim">gensim</a>.
%
%    gensim(net)
%
%  See also PREPARETS, CLOSELOOP, REMOVEDELAY, NARNET, TIMEDELAYNET, GENSIM.

% Copyright 2008-2013 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Network Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin > 0) && ischar(varargin{1}) ...
      && ~strcmpi(varargin{1},'hardlim') && ~strcmpi(varargin{1},'hardlims')
    code = varargin{1};
    switch code
      case 'info',
        out1 = INFO;
      case 'check_param'
        err = check_param(varargin{2});
        if ~isempty(err), nnerr.throw('Args',err); end
        out1 = err;
      case 'create'
        if nargin < 2, error(message('nnet:Args:NotEnough')); end
        param = varargin{2};
        err = nntest.param(INFO.parameters,param);
        if ~isempty(err), nnerr.throw('Args',err); end
        out1 = create_network(param);
        out1.name = INFO.name;
      otherwise,
        % Quick info field access
        try
          out1 = eval(['INFO.' code]);
        catch %#ok<CTCH>
          nnerr.throw(['Unrecognized argument: ''' code ''''])
        end
    end
  else
    [args,param] = nnparam.extract_param(varargin,INFO.defaultParam);
    [param,err] = INFO.overrideStructure(param,args);
    if ~isempty(err), nnerr.throw('Args',err,'Parameters'); end
    net = create_network(param);
    net.name = INFO.name;
    out1 = init(net);
  end
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnNetwork(mfilename,'NARX Neural Network',fcnversion, ...
    [ ...
    nnetParamInfo('inputDelays','Input Delays','nntype.pos_inc_int_row',[1 2],...
    'Row vector of non-feedback input delays, or 0 for no non-feedback input.'), ...
    nnetParamInfo('feedbackDelays','Feedback delays','nntype.pos_inc_int_row',[1 2],...
    'Row vector of feedback delays, usually starting with 0.'), ...
    nnetParamInfo('hiddenSizes','Hidden Layer Sizes','nntype.strict_pos_int_row',10,...
    'Sizes of 0 or more hidden layers.'), ...
    nnetParamInfo('feedbackMode','Feedback Loop Mode','nntype.feedback_mode','open',...
    'True for open loop feedback, false for closed loop feedback.'), ...
    nnetParamInfo('trainFcn','Training Function','nntype.training_fcn','trainlm',...
    'Function to train the network.'), ...
    ]);
end

function err = check_param(param)
  if (min(param.feedbackDelays) == 0)
    err = 'Minimum feedbackDelay is zero causing a zero-delay loop.';
    % TODO - Handle with separate type
  else
    err = '';
  end
end

function net = create_network(param)

  % Feed-Forward
  net = feedforwardnet(param.hiddenSizes,param.trainFcn);
  net.inputWeights{1,1}.delays = param.inputDelays;
  net.inputs{1}.name = 'x';
  
  % Feedback Output
  net.outputs{net.numLayers}.name = 'y';
  net.outputs{net.numLayers}.feedbackMode = 'open';
  net.inputConnect(1,2) = true;
  net.inputWeights{1,2}.delays = param.feedbackDelays;
  
  % Training
  net.divideFcn = 'dividerand';
  net.divideMode = 'time';
  net.performFcn = 'mse';
  net.trainFcn = param.trainFcn;
  
  % Plotting
  net.plotFcns = {'plotperform','plottrainstate','ploterrhist','plotregression',...
    'plotresponse','ploterrcorr','plotinerrcorr'};
  
  % Open/Closed Loop
  if strcmp(param.feedbackMode,'closed')
    net = closeloop(net);
  end
end
